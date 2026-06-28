import 'package:dio/dio.dart';

import '../../data/demo/demo_movies.dart';
import '../models/movie.dart';

class TmdbService {
  TmdbService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://api.themoviedb.org/3'));

  final Dio _dio;

  Future<List<Movie>> discover({String? query, int page = 1}) async {
    // Route through Firebase Cloud Functions once TMDB key is configured server-side.
    await Future<void>.delayed(const Duration(milliseconds: 250));
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
}