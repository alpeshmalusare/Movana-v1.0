const { onSchedule } = require('firebase-functions/v2/scheduler');
const { HttpsError, onCall, onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();
const db = admin.firestore();

const tmdb = axios.create({ baseURL: 'https://api.themoviedb.org/3', timeout: 12000 });

const allowedPathPatterns = [
  /^\/trending\/(movie|tv|all)\/(day|week)$/,
  /^\/movie\/(popular|top_rated|now_playing|upcoming)$/,
  /^\/tv\/(popular|top_rated|on_the_air)$/,
  /^\/genre\/(movie|tv)\/list$/,
  /^\/search\/(movie|tv|person|multi)$/,
  /^\/movie\/\d+$/,
  /^\/tv\/\d+$/,
  /^\/movie\/\d+\/(credits|recommendations|videos|watch\/providers)$/,
  /^\/movie\/\d+\/(release_dates)$/,
  /^\/tv\/\d+\/(credits|recommendations|videos|watch\/providers)$/,
];

const allowedQueryKeys = new Set([
  'language',
  'region',
  'page',
  'query',
  'year',
  'primary_release_year',
  'first_air_date_year',
  'include_adult',
  'append_to_response',
]);

const rateWindowMs = 60 * 1000;
const maxRequestsPerWindow = 60;
const requestCounts = new Map();

function isAllowedPath(path) {
  return allowedPathPatterns.some((pattern) => pattern.test(path));
}

function sanitizeQuery(query) {
  const sanitized = {};
  for (const [key, value] of Object.entries(query)) {
    if (allowedQueryKeys.has(key) && typeof value !== 'object') sanitized[key] = value;
  }
  sanitized.language = sanitized.language || 'en-IN';
  sanitized.region = sanitized.region || 'IN';
  return sanitized;
}

function assertAppAccess(req) {
  const expectedSecret = process.env.MOVANA_PROXY_SECRET;
  if (!expectedSecret) return;
  if (req.get('x-movana-proxy-secret') !== expectedSecret) {
    const error = new Error('Unauthorized proxy access');
    error.status = 401;
    throw error;
  }
}

function assertRateLimit(req) {
  const now = Date.now();
  const key = req.ip || req.get('x-forwarded-for') || 'anonymous';
  const current = requestCounts.get(key) || { count: 0, resetAt: now + rateWindowMs };
  if (now > current.resetAt) {
    requestCounts.set(key, { count: 1, resetAt: now + rateWindowMs });
    return;
  }
  if (current.count >= maxRequestsPerWindow) {
    const error = new HttpsError('resource-exhausted', 'TMDB proxy rate limit exceeded');
    error.status = 429;
    throw error;
  }
  current.count += 1;
  requestCounts.set(key, current);
}

async function tmdbGet(path, params = {}) {
  const token = process.env.TMDB_ACCESS_TOKEN;
  if (!token) throw new Error('TMDB_ACCESS_TOKEN is not configured');
  const response = await tmdb.get(path, {
    params,
    headers: { Authorization: `Bearer ${token}` },
  });
  return response.data;
}

exports.refreshMovieMetadata = onSchedule({ schedule: 'every 24 hours', region: 'asia-south1' }, async () => {
  const data = await tmdbGet('/trending/all/day', { language: 'en-IN' });
  const batch = db.batch();
  for (const item of data.results || []) {
    const id = String(item.id);
    const ref = db.collection('movies').doc(id);
    batch.set(ref, {
      movieID: id,
      title: item.title || item.name,
      overview: item.overview || '',
      poster: item.poster_path || '',
      backdrop: item.backdrop_path || '',
      rating: item.vote_average || 0,
      voteCount: item.vote_count || 0,
      releaseDate: item.release_date || item.first_air_date || '',
      contentType: item.media_type === 'tv' ? 'series' : 'movie',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }
  await batch.commit();
});

exports.tmdbCallable = onCall({ region: 'asia-south1', enforceAppCheck: false }, async (request) => {
  try {
    assertRateLimit(request.rawRequest);
    const uid = request.auth?.uid;
    if (!uid) throw new HttpsError('unauthenticated', 'Authentication is required');
    const path = request.data?.path;
    if (!path || typeof path !== 'string' || !isAllowedPath(path)) {
      throw new HttpsError('invalid-argument', 'Unsupported TMDB endpoint');
    }
    return await tmdbGet(path, sanitizeQuery(request.data?.query || {}));
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    throw new HttpsError('internal', 'TMDB callable request failed');
  }
});

exports.tmdbProxy = onRequest({ region: 'asia-south1' }, async (req, res) => {
  try {
    assertAppAccess(req);
    assertRateLimit(req);
    const path = req.query.path;
    if (!path || typeof path !== 'string' || !isAllowedPath(path)) {
      res.status(400).json({ error: 'Unsupported TMDB endpoint' });
      return;
    }
    const data = await tmdbGet(path, sanitizeQuery(req.query));
    res.set('Cache-Control', 'public, max-age=300, s-maxage=600');
    res.json(data);
  } catch (error) {
    const status = error.status || 500;
    res.status(status).json({ error: status === 500 ? 'TMDB proxy request failed' : error.message });
  }
});