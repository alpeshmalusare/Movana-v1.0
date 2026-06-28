import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/movana_theme.dart';
import '../home/discovery_controller.dart';
import 'widgets/movie_card.dart';

class MovieListingScreen extends ConsumerWidget {
  const MovieListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(filteredMoviesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Movie & Series Listing', key: ValueKey('listing-title'))),
      body: moviesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(key: ValueKey('listing-loading'))),
        error: (_, __) => const Center(child: Text('Unable to load live TMDB data', key: ValueKey('listing-error-message'))),
        data: (movies) => movies.isEmpty
            ? const Center(child: Text('Streaming Information Not Available', key: ValueKey('listing-empty-message')))
            : ListView.builder(
                key: const ValueKey('movie-listing-list'),
                padding: const EdgeInsets.all(20),
                itemCount: movies.length + (movies.length ~/ 8),
                itemBuilder: (context, index) {
                  if (index > 0 && index % 9 == 8) return const _NativeAdPlaceholder();
                  final movieIndex = index - (index ~/ 9);
                  return MovieCard(movie: movies[movieIndex]);
                },
              ),
      ),
    );
  }
}

class _NativeAdPlaceholder extends StatelessWidget {
  const _NativeAdPlaceholder();
  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('native-ad-placeholder'),
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: MovanaColors.divider)),
        child: const Text('Sponsored recommendation slot', style: TextStyle(color: MovanaColors.textSecondary)),
      );
}