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
      'append_to_response': 'credits,videos,watch/providers,release_dates,recommendations',
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

  Movie _movieFromTmdb(Map<String, dynamic> data, {bool detailed = false}) {
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
      title: data['title'] as String? ?? 'Untitled',
      overview: data['overview'] as String? ?? 'Overview not available.',
      posterUrl: _imageUrl(data['poster_path'] as String?, 'w500'),
      backdropUrl: _imageUrl(data['backdrop_path'] as String?, 'w1280'),
      genres: genres,
      runtimeMinutes: (data['runtime'] as num?)?.toInt() ?? 0,
      rating: (data['vote_average'] as num?)?.toDouble() ?? 0,
      voteCount: (data['vote_count'] as num?)?.toInt() ?? 0,
      releaseYear: _yearFrom(data['release_date'] as String?),
      providers: providers,
      director: director ?? 'Details available soon',
      cast: cast,
      language: (data['original_language'] as String? ?? '').toUpperCase(),
      ageRating: detailed ? _certificationFrom(data['release_dates']) : 'NR',
      contentType: ContentType.movie,
      writer: 'TMDB metadata',
      productionCompany: companies.isNotEmpty ? companies.first['name'] as String? ?? 'Studio information pending' : 'Studio information pending',
    );
  }

  String _imageUrl(String? path, String size) => path == null ? '' : 'https://image.tmdb.org/t/p/$size$path';
  int _yearFrom(String? date) => date == null || date.length < 4 ? 0 : int.tryParse(date.substring(0, 4)) ?? 0;

  List<String> _providersFrom(dynamic watchProviders) {
    final root = watchProviders is Map ? watchProviders['results'] : null;
    final data = root is Map ? root['IN'] : null;
    if (data is! Map) return const [];
    final names = <String>{};
    for (final bucket in ['flatrate', 'free', 'ads', 'rent', 'buy']) {
      for (final provider in (data[bucket] as List<dynamic>? ?? const [])) {
        if (provider is Map && provider['provider_name'] is String) names.add(provider['provider_name'] as String);
      }
    }
    return names.toList();
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
}