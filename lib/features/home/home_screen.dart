import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/movie.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/movana_theme.dart';
import '../movies/widgets/movie_card.dart';
import 'discovery_controller.dart';
import 'widgets/genre_selector.dart';
import 'widgets/platform_selector.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final moviesAsync = ref.watch(filteredMoviesProvider);
    final discovery = ref.watch(discoveryProvider);
    return SafeArea(
      child: CustomScrollView(
        key: const ValueKey('home-scroll-view'),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverList.list(children: [
              Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Hello, ${user?.name ?? 'Movana User'}', key: const ValueKey('home-greeting'), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('Find the highest-rated stories across OTT.', key: ValueKey('home-subtitle'), style: TextStyle(color: MovanaColors.textSecondary)),
                    ]),
                  ),
                  IconButton(
                    key: const ValueKey('admin-dashboard-button'),
                    onPressed: () => context.push('/admin'),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              TextField(
                key: const ValueKey('home-search-field'),
                onChanged: ref.read(discoveryProvider.notifier).setQuery,
                decoration: InputDecoration(
                  hintText: 'Search movies, series, actors, directors, studios',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: MovanaColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeader(title: 'Choose OTT Platforms', action: '${discovery.platforms.length} selected'),
              const SizedBox(height: 14),
              const PlatformSelector(),
              const SizedBox(height: 28),
              _SectionHeader(title: 'Content Type', action: 'Movies or Series'),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                key: const ValueKey('content-type-segment'),
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'movie', label: Text('Movies')),
                  ButtonSegment(value: 'series', label: Text('Series')),
                ],
                selected: {discovery.contentType?.name ?? 'all'},
                onSelectionChanged: (value) {
                  final selected = value.first;
                  ref.read(discoveryProvider.notifier).setContentType(
                        selected == 'movie'
                            ? ContentType.movie
                            : selected == 'series'
                                ? ContentType.series
                                : null,
                      );
                },
              ),
              const SizedBox(height: 28),
              _SectionHeader(title: 'Genres', action: '${discovery.genres.length} selected'),
              const SizedBox(height: 12),
              const GenreSelector(),
              const SizedBox(height: 28),
              _FilterRow(),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: _SectionHeader(title: 'Top Picks', action: '')),
                  TextButton(key: const ValueKey('view-all-movies-button'), onPressed: () => context.push('/movies'), child: const Text('View all')),
                ],
              ),
            ]),
          ),
          ...moviesAsync.when(
            loading: () => const [SliverFillRemaining(child: Center(child: CircularProgressIndicator(key: ValueKey('tmdb-loading-indicator'))))],
            error: (error, _) => [SliverFillRemaining(child: Center(child: Text('Unable to load live TMDB data', key: const ValueKey('tmdb-error-message'), style: const TextStyle(color: MovanaColors.textSecondary))))],
            data: (movies) => movies.isEmpty
                ? const [SliverFillRemaining(child: Center(child: Text('Streaming Information Not Available', key: ValueKey('empty-results-message'))))]
                : [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      sliver: SliverList.builder(
                        itemCount: movies.take(4).length,
                        itemBuilder: (_, index) => MovieCard(movie: movies[index]),
                      ),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});
  final String title;
  final String action;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, key: ValueKey('section-title-$title'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
        if (action.isNotEmpty) Text(action, key: ValueKey('section-action-$title'), style: const TextStyle(color: MovanaColors.textSecondary)),
      ]);
}

class _FilterRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryProvider);
    return Column(
      key: const ValueKey('filters-section'),
      children: [
        _DropdownFilter(label: 'Rating', value: state.ratingFilter, items: const ['Top Rated', 'Rating 8.0–10.0', 'Rating 6.0–8.0', 'Rating 4.0–6.0', 'Rating 1.0–4.0'], onChanged: ref.read(discoveryProvider.notifier).setRatingFilter),
        const SizedBox(height: 10),
        _DropdownFilter(label: 'Year', value: state.sortFilter, items: const ['All Time', 'Latest to Oldest', 'Oldest to Latest'], onChanged: ref.read(discoveryProvider.notifier).setSortFilter),
        const SizedBox(height: 10),
        _DropdownFilter(label: 'Language', value: state.languageFilter, items: const ['All Languages', ...AppConstants.languages], onChanged: ref.read(discoveryProvider.notifier).setLanguageFilter),
      ],
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  const _DropdownFilter({required this.label, required this.value, required this.items, required this.onChanged});
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        key: ValueKey('filter-$label'),
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        decoration: InputDecoration(labelText: label, filled: true, fillColor: MovanaColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
      );
}