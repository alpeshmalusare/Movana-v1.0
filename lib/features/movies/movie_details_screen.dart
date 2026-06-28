import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/demo/demo_movies.dart';
import '../../core/services/library_service.dart';
import '../../core/theme/movana_theme.dart';
import 'widgets/movie_card.dart';

class MovieDetailsScreen extends ConsumerWidget {
  const MovieDetailsScreen({super.key, required this.movieId});
  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = demoMovies.firstWhere((item) => item.id == movieId, orElse: () => demoMovies.first);
    final library = ref.watch(libraryProvider);
    final watched = library.watched.contains(movie.id);
    final saved = library.watchlist.contains(movie.id);
    final similar = demoMovies.where((item) => item.id != movie.id).take(2).toList();
    return Scaffold(
      body: CustomScrollView(
        key: ValueKey('movie-details-${movie.id}'),
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                CachedNetworkImage(imageUrl: movie.backdropUrl, fit: BoxFit.cover),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, MovanaColors.background]))),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(children: [
              Text(movie.title, key: ValueKey('details-title-${movie.id}'), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Text('${movie.releaseYear} • ${movie.runtimeMinutes} min • ${movie.ageRating}', key: ValueKey('details-meta-${movie.id}'), style: const TextStyle(color: MovanaColors.textSecondary)),
              const SizedBox(height: 12),
              Row(children: [const Icon(Icons.star_rounded, color: MovanaColors.accent), const SizedBox(width: 6), Text('${movie.rating} • ${movie.voteCount} votes', key: ValueKey('details-rating-${movie.id}'), style: const TextStyle(fontWeight: FontWeight.w800))]),
              const SizedBox(height: 18),
              Wrap(spacing: 8, runSpacing: 8, children: movie.genres.map((genre) => Chip(key: ValueKey('details-genre-$genre'), label: Text(genre))).toList()),
              const SizedBox(height: 24),
              Text(movie.overview, key: ValueKey('details-overview-${movie.id}'), style: const TextStyle(color: MovanaColors.textSecondary, height: 1.5)),
              const SizedBox(height: 22),
              _InfoLine(label: 'Director', value: movie.director),
              _InfoLine(label: 'Writer', value: movie.writer),
              _InfoLine(label: 'Cast', value: movie.cast.join(', ')),
              _InfoLine(label: 'Production', value: movie.productionCompany),
              _InfoLine(label: 'Streaming', value: movie.providers.isEmpty ? 'Currently in Theatres' : movie.providers.join(', ')),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(child: FilledButton.icon(key: ValueKey('details-trailer-${movie.id}'), onPressed: () {}, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Trailer'))),
                const SizedBox(width: 10),
                IconButton.filledTonal(key: ValueKey('details-share-${movie.id}'), onPressed: () => Share.share('Watch ${movie.title} on Movana'), icon: const Icon(Icons.share_rounded)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: OutlinedButton.icon(key: ValueKey('details-watched-${movie.id}'), onPressed: () => ref.read(libraryProvider.notifier).toggleWatched(movie), icon: Icon(watched ? Icons.check_circle : Icons.visibility_outlined), label: Text(watched ? 'Watched' : 'Already Watched'))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(key: ValueKey('details-watchlist-${movie.id}'), onPressed: () => ref.read(libraryProvider.notifier).toggleWatchlist(movie), icon: Icon(saved ? Icons.favorite : Icons.favorite_border, color: saved ? MovanaColors.watchlist : null), label: Text(saved ? 'Saved' : 'Watchlist'))),
              ]),
              const SizedBox(height: 30),
              const Text('Similar Movies', key: ValueKey('similar-movies-title'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              for (final item in similar) MovieCard(movie: item, compact: true),
              const SizedBox(height: 20),
              const Text('Reviews', key: ValueKey('reviews-title'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              const Text('User reviews and ratings module is ready for Firestore-backed expansion.', key: ValueKey('reviews-placeholder'), style: TextStyle(color: MovanaColors.textSecondary)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RichText(
          key: ValueKey('details-info-$label'),
          text: TextSpan(style: DefaultTextStyle.of(context).style, children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: value, style: const TextStyle(color: MovanaColors.textSecondary)),
          ]),
        ),
      );
}