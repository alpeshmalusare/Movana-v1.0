const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onRequest } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();
const db = admin.firestore();

const tmdb = axios.create({ baseURL: 'https://api.themoviedb.org/3', timeout: 12000 });

async function tmdbGet(path, params = {}) {
  const token = process.env.TMDB_ACCESS_TOKEN;
  if (!token) throw new Error('TMDB_ACCESS_TOKEN is not configured');
  const response = await tmdb.get(path, {
    params,
    headers: { Authorization: `Bearer ${token}` },
  });
  return response.data;
}

exports.refreshMovieMetadata = onSchedule('every 24 hours', async () => {
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

exports.tmdbProxy = onRequest(async (req, res) => {
  try {
    const path = req.query.path;
    if (!path || typeof path !== 'string' || !path.startsWith('/')) {
      res.status(400).json({ error: 'Valid path query is required' });
      return;
    }
    const data = await tmdbGet(path, req.query);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});