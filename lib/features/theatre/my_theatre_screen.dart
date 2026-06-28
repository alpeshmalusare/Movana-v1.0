import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/library_service.dart';
import '../../core/theme/movana_theme.dart';
import '../../data/demo/demo_movies.dart';

class MyTheatreScreen extends ConsumerWidget {
  const MyTheatreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchedIds = ref.watch(libraryProvider).watched;
    final watched = demoMovies.where((movie) => watchedIds.contains(movie.id)).toList();
    final hours = watched.fold<int>(0, (sum, movie) => sum + movie.runtimeMinutes) ~/ 60;
    final avg = watched.isEmpty ? 0.0 : watched.map((e) => e.rating).reduce((a, b) => a + b) / watched.length;
    return SafeArea(
      child: ListView(
        key: const ValueKey('my-theatre-screen'),
        padding: const EdgeInsets.all(20),
        children: [
          const Text('My Theatre', key: ValueKey('theatre-title'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          Container(
            key: const ValueKey('shareable-stats-card'),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.asset(AppAssets.icon, width: 42),
              const SizedBox(height: 18),
              Text('I’ve watched ${watched.length} titles', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Average Rating ${avg.toStringAsFixed(1)} • $hours hours watched', style: const TextStyle(color: MovanaColors.textSecondary)),
              const SizedBox(height: 12),
              const Text('Shared from Movana', style: TextStyle(color: MovanaColors.accent, fontWeight: FontWeight.w800)),
            ]),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(key: const ValueKey('share-theatre-button'), onPressed: () => Share.share('I’ve watched ${watched.length} titles on Movana. Average rating ${avg.toStringAsFixed(1)}'), icon: const Icon(Icons.ios_share), label: const Text('Generate Share Image')),
          const SizedBox(height: 26),
          Wrap(spacing: 12, runSpacing: 12, children: [
            _StatCard(label: 'Movies Watched', value: watched.where((m) => m.contentType.name == 'movie').length.toString()),
            _StatCard(label: 'Series Watched', value: watched.where((m) => m.contentType.name == 'series').length.toString()),
            _StatCard(label: 'Favourite Genre', value: watched.isEmpty ? '—' : watched.first.genres.first),
            _StatCard(label: 'Favourite OTT', value: watched.isEmpty || watched.first.providers.isEmpty ? '—' : watched.first.providers.first),
            _StatCard(label: 'Favourite Actor', value: watched.isEmpty ? '—' : watched.first.cast.first),
            _StatCard(label: 'Favourite Director', value: watched.isEmpty ? '—' : watched.first.director),
          ]),
          const SizedBox(height: 28),
          const Text('Achievements', key: ValueKey('achievements-title'), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const _Achievement(label: 'Watched 100 Movies'),
          const _Achievement(label: 'Watched 250 Movies'),
          const _Achievement(label: 'Watched Every Christopher Nolan Movie'),
          const _Achievement(label: 'Watched Every Harry Potter Movie'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey('stat-card-$label'),
        width: 158,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 6), Text(label, style: const TextStyle(color: MovanaColors.textSecondary))]),
      );
}

class _Achievement extends StatelessWidget {
  const _Achievement({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => ListTile(key: ValueKey('achievement-$label'), leading: const Icon(Icons.workspace_premium_outlined, color: MovanaColors.accent), title: Text(label), subtitle: const Text('Locked', style: TextStyle(color: MovanaColors.textSecondary)));
}