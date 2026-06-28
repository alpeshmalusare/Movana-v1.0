import 'dart:convert';

import 'package:dio/dio.dart';

import '../../data/demo/demo_movies.dart';
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

  Future<List<Movie>> discover({String? query, int page = 1}) async {
    await _warmTmdbCache(query: query, page: page);
    final normalized = query?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return demoMovies;
    return demoMovies.where((movie) {
      return movie.title.toLowerCase().contains(normalized) ||
          movie.director.toLowerCase().contains(normalized) ||
          movie.cast.any((actor) => actor.toLowerCase().contains(normalized)) ||
          movie.providers.any((provider) => provider.toLowerCase().contains(normalized));
    }).toList();
  }

  Future<Movie?> details(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    for (final movie in demoMovies) {
      if (movie.id == id) return movie;
    }
    return null;
  }

  Future<Response<dynamic>> rawGet(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<void> _warmTmdbCache({String? query, int page = 1}) async {
    try {
      final path = query == null || query.trim().isEmpty ? '/trending/all/day' : '/search/multi';
      final data = await _functionsService.tmdbProxy(path: path, query: {
        if (query != null && query.trim().isNotEmpty) 'query': query.trim(),
        'page': page,
      });
      await _cache.saveJson('tmdb_${path}_$page', jsonEncode(data));
    } catch (_) {
      // Demo catalog remains available offline or when TMDB secret is not configured.
    }
  }
}