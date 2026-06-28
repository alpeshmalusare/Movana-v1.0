import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/movie.dart';
import '../../../core/services/library_service.dart';
import '../../../core/theme/movana_theme.dart';

class MovieCard extends ConsumerWidget {
  const MovieCard({super.key, required this.movie, this.compact = false});

  final Movie movie;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final watched = library.watched.contains(movie.id);
    final watchlisted = library.watchlist.contains(movie.id);
    return Card(
      key: ValueKey('movie-card-${movie.id}'),
      margin: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/movie/${movie.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  key: ValueKey('movie-poster-${movie.id}'),
                  imageUrl: movie.posterUrl,
                  width: compact ? 86 : 104,
                  height: compact ? 128 : 156,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, key: ValueKey('movie-title-${movie.id}'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('${movie.releaseYear} • ${movie.runtimeMinutes} min • ${movie.language}', key: ValueKey('movie-meta-${movie.id}'), style: const TextStyle(color: MovanaColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: MovanaColors.accent, size: 18),
                        const SizedBox(width: 4),
                        Text('${movie.rating.toStringAsFixed(1)}  (${movie.voteCount})', key: ValueKey('movie-rating-${movie.id}'), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(movie.genres.join(' • '), key: ValueKey('movie-genres-${movie.id}'), style: const TextStyle(color: MovanaColors.textSecondary)),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      Text(movie.overview, key: ValueKey('movie-overview-${movie.id}'), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: MovanaColors.textSecondary, height: 1.35)),
                      const SizedBox(height: 10),
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        if (movie.isStreaming)
                          for (final provider in movie.providers) _MiniPill(label: provider)
                        else
                          const _MiniPill(label: 'Currently in Theatres'),
                      ]),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ActionButton(
                          key: ValueKey('watched-button-${movie.id}'),
                          active: watched,
                          activeColor: MovanaColors.accent,
                          icon: watched ? Icons.check_circle : Icons.visibility_outlined,
                          label: watched ? 'Watched' : 'Already Watched',
                          onTap: () => ref.read(libraryProvider.notifier).toggleWatched(movie),
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          key: ValueKey('watchlist-button-${movie.id}'),
                          active: watchlisted,
                          activeColor: MovanaColors.watchlist,
                          icon: watchlisted ? Icons.favorite : Icons.favorite_border,
                          label: watchlisted ? 'Saved' : 'Watchlist',
                          onTap: () => ref.read(libraryProvider.notifier).toggleWatchlist(movie),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey('provider-pill-$label'),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: MovanaColors.background, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: const TextStyle(fontSize: 11, color: MovanaColors.textSecondary)),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({super.key, required this.active, required this.activeColor, required this.icon, required this.label, required this.onTap});
  final bool active;
  final Color activeColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 16),
          label: Text(label, overflow: TextOverflow.ellipsis),
          style: OutlinedButton.styleFrom(
            foregroundColor: active ? activeColor : MovanaColors.textSecondary,
            side: BorderSide(color: active ? activeColor : MovanaColors.divider),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}