import 'dart:convert';

import 'package:dio/dio.dart';

import 'functions_service.dart';
import 'offline_cache_service.dart';
import '../models/movie.dart';

class TmdbService {
  TmdbService({Dio? dio, FunctionsService? functionsService, OfflineCacheService? cache})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.themoviedb.org/3')),
        _functionsService = functionsService ?? FunctionsService(),
        _cache = cache ?? OfflineCacheService();

  final Dio _dio;
  final FunctionsService _functionsService;
  final OfflineCacheService _cache;

  Future<List<Movie>> trending({int page = 1}) => _list('/trending/movie/day', page: page);
  Future<List<Movie>> popular({int page = 1}) => _list('/movie/popular', page: page);
  Future<List<Movie>> topRated({int page = 1}) => _list('/movie/top_rated', page: page);
  Future<List<Movie>> nowPlaying({int page = 1}) => _list('/movie/now_playing', page: page);
  Future<List<Movie>> upcoming({int page = 1}) => _list('/movie/upcoming', page: page);

  Future<List<Movie>> discoverByFlow({
    required String contentType,
    required String genre,
    required String providerId,
    String rating = 'top',
    String time = 'all',
    String language = 'all',
    int page = 1,
  }) async {
    // Firebase callable proxies TMDB discover endpoints. Genre names are resolved client-side for common genres.
    final genreId = _genreIds[genre] ?? 18;
    final type = contentType == 'series' ? 'tv' : 'movie';
    final data = await _functionsService.tmdbProxy(path: '/discover/$type', query: {
      'page': page,
      'with_genres': genreId,
      'watch_region': 'IN',
      'with_watch_providers': providerId,
      'sort_by': time == 'latest'
          ? (type == 'movie' ? 'primary_release_date.desc' : 'first_air_date.desc')
          : time == 'oldest'
              ? (type == 'movie' ? 'primary_release_date.asc' : 'first_air_date.asc')
              : 'vote_average.desc',
      'vote_count.gte': 250,
      if (rating == '8_10') 'vote_average.gte': 8,
      if (rating == '6_8') 'vote_average.gte': 6,
      if (rating == '6_8') 'vote_average.lte': 8,
      if (rating == '4_6') 'vote_average.gte': 4,
      if (rating == '4_6') 'vote_average.lte': 6,
      if (rating == '1_4') 'vote_average.gte': 1,
      if (rating == '1_4') 'vote_average.lte': 4,
      if (language != 'all') 'with_original_language': language,
    });
    final results = data['results'] as List<dynamic>? ?? const [];
    return results.whereType<Map>().map((item) => _movieFromTmdb(Map<String, dynamic>.from(item), contentTypeOverride: type)).where((movie) => movie.posterUrl.isNotEmpty).toList();
  }

  Future<List<Movie>> discover({String? query, int page = 1}) {
    if (query != null && query.trim().isNotEmpty) {
      return search(query.trim(), page: page);
    }
    return trending(page: page);
  }

  Future<List<Movie>> search(String query, {int page = 1}) async {
    return _list('/search/movie', page: page, query: {'query': query, 'include_adult': false});
  }

  Future<Movie?> details(String id) async {
    final data = await _functionsService.tmdbProxy(path: '/movie/$id', query: {
      'append_to_response': 'credits,videos,watch/providers,release_dates,recommendations,similar,images',
    });
    await _cache.saveJson('tmdb_movie_$id', jsonEncode(data));
    return _movieFromTmdb(data, detailed: true);
  }

  Future<Response<dynamic>> rawGet(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<List<Movie>> _list(String path, {int page = 1, Map<String, dynamic> query = const {}}) async {
    final data = await _functionsService.tmdbProxy(path: path, query: {'page': page, ...query});
    await _cache.saveJson('tmdb_${path}_$page', jsonEncode(data));
    final results = data['results'] as List<dynamic>? ?? const [];
    return results
        .whereType<Map>()
        .map((item) => _movieFromTmdb(Map<String, dynamic>.from(item)))
        .where((movie) => movie.posterUrl.isNotEmpty)
        .toList();
  }

  Movie _movieFromTmdb(Map<String, dynamic> data, {bool detailed = false, String? contentTypeOverride}) {
    final isSeries = contentTypeOverride == 'tv' || data['name'] != null || data['first_air_date'] != null;
    final genres = (data['genres'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((genre) => genre['name'] as String?)
        .whereType<String>()
        .toList();
    final providers = _providersFrom(data['watch/providers']);
    final credits = data['credits'] as Map<String, dynamic>?;
    final cast = (credits?['cast'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .take(5)
        .map((person) => person['name'] as String?)
        .whereType<String>()
        .toList();
    String? director;
    for (final person in (credits?['crew'] as List<dynamic>? ?? const []).whereType<Map>()) {
      if (person['job'] == 'Director' && person['name'] is String) {
        director = person['name'] as String;
        break;
      }
    }
    final companies = (data['production_companies'] as List<dynamic>? ?? const []).whereType<Map>().toList();
    return Movie(
      id: '${data['id']}',
      title: data['title'] as String? ?? data['name'] as String? ?? 'Untitled',
      overview: data['overview'] as String? ?? 'Overview not available.',
      posterUrl: _imageUrl(data['poster_path'] as String?, 'w500'),
      backdropUrl: _imageUrl(data['backdrop_path'] as String?, 'w1280'),
      genres: genres,
      runtimeMinutes: (data['runtime'] as num?)?.toInt() ?? 0,
      rating: (data['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (data['vote_count'] as num?)?.toInt() ?? 0,
      releaseYear: _yearFrom(data['release_date'] as String? ?? data['first_air_date'] as String?),
      providers: providers,
      director: director ?? 'Details available soon',
      cast: cast,
      language: (data['original_language'] as String? ?? '').toUpperCase(),
      ageRating: detailed ? _certificationFrom(data['release_dates']) : 'NR',
      contentType: isSeries ? ContentType.series : ContentType.movie,
      writer: 'TMDB metadata',
      productionCompany: companies.isNotEmpty ? companies.first['name'] as String? ?? 'Studio information pending' : 'Studio information pending',
      originalTitle: data['original_title'] as String? ?? data['original_name'] as String? ?? '',
      releaseDate: data['release_date'] as String? ?? data['first_air_date'] as String? ?? '',
      popularity: (data['popularity'] as num?)?.toDouble() ?? 0,
      country: ((data['production_countries'] as List<dynamic>? ?? const []).whereType<Map>().map((e) => e['name'] as String?).whereType<String>().join(', ')),
      status: data['status'] as String? ?? '',
      tagline: data['tagline'] as String? ?? '',
      whereToWatch: _providerObjectsFrom(data['watch/providers']),
      topCast: _castObjectsFrom(data['credits']),
      crewRoles: _crewRolesFrom(data['credits']),
      backdrops: ((data['images'] as Map?)?['backdrops'] as List<dynamic>? ?? const []).whereType<Map>().take(10).map((e) => _imageUrl(e['file_path'] as String?, 'w780')).where((e) => e.isNotEmpty).toList(),
      posters: ((data['images'] as Map?)?['posters'] as List<dynamic>? ?? const []).whereType<Map>().take(10).map((e) => _imageUrl(e['file_path'] as String?, 'w500')).where((e) => e.isNotEmpty).toList(),
    );
  }

  String _imageUrl(String? path, String size) => path == null ? '' : 'https://image.tmdb.org/t/p/$size$path';
  int _yearFrom(String? date) => date == null || date.length < 4 ? 0 : int.tryParse(date.substring(0, 4)) ?? 0;

  List<String> _providersFrom(dynamic watchProviders) {
    return _providerObjectsFrom(watchProviders).map((e) => e['name'] ?? '').where((e) => e.isNotEmpty).toList();
  }

  List<Map<String, String>> _providerObjectsFrom(dynamic watchProviders) {
    final root = watchProviders is Map ? watchProviders['results'] : null;
    final data = root is Map ? root['IN'] : null;
    if (data is! Map) return const [];
    final providers = <Map<String, String>>[];
    final seen = <String>{};
    for (final bucket in ['flatrate', 'free', 'ads', 'rent', 'buy']) {
      for (final provider in (data[bucket] as List<dynamic>? ?? const [])) {
        if (provider is Map && provider['provider_name'] is String && !seen.contains('${provider['provider_id']}')) {
          seen.add('${provider['provider_id']}');
          providers.add({'id': '${provider['provider_id']}', 'name': provider['provider_name'] as String, 'logo': _imageUrl(provider['logo_path'] as String?, 'w300')});
        }
      }
    }
    return providers;
  }

  List<Map<String, String>> _castObjectsFrom(dynamic credits) {
    final cast = credits is Map ? credits['cast'] as List<dynamic>? : null;
    return (cast ?? const []).whereType<Map>().take(20).map((person) => {'name': '${person['name'] ?? ''}', 'character': '${person['character'] ?? ''}', 'photo': _imageUrl(person['profile_path'] as String?, 'w185')}).toList();
  }

  Map<String, List<String>> _crewRolesFrom(dynamic credits) {
    final crew = credits is Map ? credits['crew'] as List<dynamic>? : null;
    final roles = {'Director': <String>[], 'Writer': <String>[], 'Producer': <String>[], 'Music Composer': <String>[]};
    for (final person in (crew ?? const []).whereType<Map>()) {
      final name = person['name'] as String?;
      final job = person['job'] as String?;
      if (name == null || job == null) continue;
      if (job == 'Director') roles['Director']!.add(name);
      if (['Writer', 'Screenplay', 'Story', 'Novel'].contains(job)) roles['Writer']!.add(name);
      if (job == 'Producer') roles['Producer']!.add(name);
      if (['Original Music Composer', 'Music', 'Composer'].contains(job)) roles['Music Composer']!.add(name);
    }
    return roles;
  }

  String _certificationFrom(dynamic releaseDates) {
    final results = releaseDates is Map ? releaseDates['results'] as List<dynamic>? : null;
    for (final country in results ?? const []) {
      if (country is Map && country['iso_3166_1'] == 'IN') {
        for (final release in (country['release_dates'] as List<dynamic>? ?? const [])) {
          if (release is Map && release['certification'] is String && (release['certification'] as String).isNotEmpty) {
            return release['certification'] as String;
          }
        }
      }
    }
    return 'NR';
  }

  static const _genreIds = {
    'Action': 28,
    'Adventure': 12,
    'Animation': 16,
    'Comedy': 35,
    'Crime': 80,
    'Documentary': 99,
    'Drama': 18,
    'Family': 10751,
    'Fantasy': 14,
    'History': 36,
    'Horror': 27,
    'Music': 10402,
    'Mystery': 9648,
    'Romance': 10749,
    'Sci-Fi': 878,
    'Science Fiction': 878,
    'Thriller': 53,
    'War': 10752,
    'Western': 37,
  };
}