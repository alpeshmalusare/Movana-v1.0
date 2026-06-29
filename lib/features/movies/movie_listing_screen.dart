import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/movana_theme.dart';
import '../home/discovery_controller.dart';
import 'widgets/movie_card.dart';

class MovieListingScreen extends ConsumerWidget {
  const MovieListingScreen({super.key, this.platform, this.contentType, this.genre});

  final String? platform;
  final String? contentType;
  final String? genre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moviesAsync = ref.watch(filteredMoviesProvider);
    return Scaffold(
      appBar: AppBar(title: Text('${genre ?? 'Top Rated'} ${contentType == 'series' ? 'Series' : 'Movies'}', key: const ValueKey('listing-title'))),
      body: moviesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(key: ValueKey('listing-loading'))),
        error: (_, __) => const Center(child: Text('Unable to load live TMDB data', key: ValueKey('listing-error-message'))),
        data: (movies) => movies.isEmpty
            ? const Center(child: Text('Streaming Information Not Available', key: ValueKey('listing-empty-message')))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Row(children: const [Expanded(child: _FilterChip(label: 'Top Rated')), SizedBox(width: 10), Expanded(child: _FilterChip(label: 'All Time'))]),
                  ),
                  Expanded(
                    child: ListView.builder(
                      key: const ValueKey('movie-listing-list'),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: movies.length,
                      itemBuilder: (context, index) => MovieCard(movie: movies[index]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(key: ValueKey('listing-filter-$label'), height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(14)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)));
}