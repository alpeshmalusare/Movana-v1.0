import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/movie.dart';
import '../../core/services/tmdb_service.dart';

class DiscoveryState {
  const DiscoveryState({
    this.query = '',
    this.platforms = const {},
    this.genres = const {},
    this.contentType,
    this.ratingFilter = 'Top Rated',
    this.sortFilter = 'All Time',
    this.languageFilter = 'All Languages',
  });

  final String query;
  final Set<String> platforms;
  final Set<String> genres;
  final ContentType? contentType;
  final String ratingFilter;
  final String sortFilter;
  final String languageFilter;

  DiscoveryState copyWith({
    String? query,
    Set<String>? platforms,
    Set<String>? genres,
    ContentType? contentType,
    bool clearContentType = false,
    String? ratingFilter,
    String? sortFilter,
    String? languageFilter,
  }) {
    return DiscoveryState(
      query: query ?? this.query,
      platforms: platforms ?? this.platforms,
      genres: genres ?? this.genres,
      contentType: clearContentType ? null : contentType ?? this.contentType,
      ratingFilter: ratingFilter ?? this.ratingFilter,
      sortFilter: sortFilter ?? this.sortFilter,
      languageFilter: languageFilter ?? this.languageFilter,
    );
  }
}

class DiscoveryController extends StateNotifier<DiscoveryState> {
  DiscoveryController() : super(const DiscoveryState());

  void setQuery(String value) => state = state.copyWith(query: value);

  void togglePlatform(String platform) {
    final next = {...state.platforms};
    next.contains(platform) ? next.remove(platform) : next.add(platform);
    state = state.copyWith(platforms: next);
  }

  void toggleGenre(String genre) {
    final next = {...state.genres};
    next.contains(genre) ? next.remove(genre) : next.add(genre);
    state = state.copyWith(genres: next);
  }

  void setContentType(ContentType? type) => state = state.copyWith(contentType: type, clearContentType: type == null);
  void setRatingFilter(String value) => state = state.copyWith(ratingFilter: value);
  void setSortFilter(String value) => state = state.copyWith(sortFilter: value);
  void setLanguageFilter(String value) => state = state.copyWith(languageFilter: value);
}

final discoveryProvider = StateNotifierProvider<DiscoveryController, DiscoveryState>((ref) => DiscoveryController());

final tmdbServiceProvider = Provider<TmdbService>((ref) => TmdbService());

final liveMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final state = ref.watch(discoveryProvider);
  return ref.watch(tmdbServiceProvider).discover(query: state.query, page: 1);
});

final tmdbMovieDetailsProvider = FutureProvider.family<Movie, String>((ref, movieId) async {
  final movie = await ref.watch(tmdbServiceProvider).details(movieId);
  if (movie == null) throw StateError('Movie not found');
  return movie;
});

class FlowMovieQuery {
  const FlowMovieQuery({required this.platform, required this.providerId, required this.contentType, required this.genre, this.rating = 'top', this.time = 'all', this.language = 'all'});
  final String platform;
  final String providerId;
  final String contentType;
  final String genre;
  final String rating;
  final String time;
  final String language;
}

final flowMoviesProvider = FutureProvider.family<List<Movie>, FlowMovieQuery>((ref, query) {
  return ref.watch(tmdbServiceProvider).discoverByFlow(contentType: query.contentType, genre: query.genre, providerId: query.providerId, rating: query.rating, time: query.time, language: query.language);
});

final filteredMoviesProvider = FutureProvider<List<Movie>>((ref) async {
  final state = ref.watch(discoveryProvider);
  Iterable<Movie> movies = await ref.watch(liveMoviesProvider.future);

  final query = state.query.trim().toLowerCase();
  if (query.isNotEmpty) {
    movies = movies.where((movie) {
      return movie.title.toLowerCase().contains(query) ||
          movie.director.toLowerCase().contains(query) ||
          movie.cast.any((actor) => actor.toLowerCase().contains(query)) ||
          movie.providers.any((provider) => provider.toLowerCase().contains(query)) ||
          movie.productionCompany.toLowerCase().contains(query);
    });
  }
  if (state.platforms.isNotEmpty) {
    movies = movies.where((movie) => movie.providers.any(state.platforms.contains));
  }
  if (state.genres.isNotEmpty) {
    movies = movies.where((movie) => movie.genres.any(state.genres.contains));
  }
  if (state.contentType != null) {
    movies = movies.where((movie) => movie.contentType == state.contentType);
  }
  if (state.languageFilter != 'All Languages') {
    movies = movies.where((movie) => movie.language == state.languageFilter);
  }
  movies = movies.where((movie) {
    switch (state.ratingFilter) {
      case 'Rating 8.0–10.0':
        return movie.rating >= 8;
      case 'Rating 6.0–8.0':
        return movie.rating >= 6 && movie.rating < 8;
      case 'Rating 4.0–6.0':
        return movie.rating >= 4 && movie.rating < 6;
      case 'Rating 1.0–4.0':
        return movie.rating >= 1 && movie.rating < 4;
      default:
        return true;
    }
  });
  final list = movies.toList();
  if (state.sortFilter == 'Latest to Oldest') {
    list.sort((a, b) => b.releaseYear.compareTo(a.releaseYear));
  } else if (state.sortFilter == 'Oldest to Latest') {
    list.sort((a, b) => a.releaseYear.compareTo(b.releaseYear));
  } else {
    list.sort((a, b) => b.rating.compareTo(a.rating));
  }
  return list;
});