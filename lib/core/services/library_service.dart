import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';

class LibraryState {
  const LibraryState({this.watchlist = const {}, this.watched = const {}});

  final Set<String> watchlist;
  final Set<String> watched;

  LibraryState copyWith({Set<String>? watchlist, Set<String>? watched}) {
    return LibraryState(
      watchlist: watchlist ?? this.watchlist,
      watched: watched ?? this.watched,
    );
  }
}

class LibraryController extends StateNotifier<LibraryState> {
  LibraryController() : super(const LibraryState());

  void toggleWatchlist(Movie movie) {
    final updated = {...state.watchlist};
    updated.contains(movie.id) ? updated.remove(movie.id) : updated.add(movie.id);
    state = state.copyWith(watchlist: updated);
  }

  void toggleWatched(Movie movie) {
    final updated = {...state.watched};
    updated.contains(movie.id) ? updated.remove(movie.id) : updated.add(movie.id);
    state = state.copyWith(watched: updated);
  }
}

final libraryProvider = StateNotifierProvider<LibraryController, LibraryState>((ref) {
  return LibraryController();
});