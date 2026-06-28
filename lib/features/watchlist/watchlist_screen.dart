import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/library_service.dart';
import '../home/discovery_controller.dart';
import '../movies/widgets/movie_card.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(libraryProvider).watchlist;
    final liveMovies = ref.watch(liveMoviesProvider).valueOrNull ?? const [];
    final movies = liveMovies.where((movie) => ids.contains(movie.id)).toList();
    return SafeArea(
      child: ListView(
        key: const ValueKey('watchlist-screen'),
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Watchlist', key: ValueKey('watchlist-title'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          TextField(key: const ValueKey('watchlist-search-field'), decoration: InputDecoration(hintText: 'Search saved titles', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)))),
          const SizedBox(height: 18),
          if (movies.isEmpty)
            const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: Text('Your Watchlist is empty. Save titles from Home.', key: ValueKey('watchlist-empty'))))
          else
            for (final movie in movies) MovieCard(movie: movie),
        ],
      ),
    );
  }
}