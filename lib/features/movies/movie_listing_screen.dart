import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/movana_theme.dart';
import '../home/discovery_controller.dart';
import 'widgets/movie_card.dart';

class MovieListingScreen extends ConsumerStatefulWidget {
  const MovieListingScreen({super.key, this.platform, this.providerId, this.contentType, this.genre});

  final String? platform;
  final String? providerId;
  final String? contentType;
  final String? genre;

  @override
  ConsumerState<MovieListingScreen> createState() => _MovieListingScreenState();
}

class _MovieListingScreenState extends ConsumerState<MovieListingScreen> {
  String rating = 'top';
  String time = 'all';
  String language = 'all';

  @override
  Widget build(BuildContext context) {
    final moviesAsync = ref.watch(flowMoviesProvider(FlowMovieQuery(platform: widget.platform ?? 'Movana', providerId: widget.providerId ?? '8', contentType: widget.contentType ?? 'movie', genre: widget.genre ?? 'Drama', rating: rating, time: time, language: language)));
    return Scaffold(
      appBar: AppBar(title: Text('${widget.genre ?? 'Top Rated'} ${widget.contentType == 'series' ? 'Series' : 'Movies'}', key: const ValueKey('listing-title'))),
      body: moviesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(key: ValueKey('listing-loading'))),
        error: (_, __) => const Center(child: Text('Unable to load live TMDB data', key: ValueKey('listing-error-message'))),
        data: (movies) => movies.isEmpty
            ? const Center(child: Text('Streaming Information Not Available', key: ValueKey('listing-empty-message')))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: Wrap(spacing: 10, runSpacing: 10, children: [
                      SizedBox(width: 150, child: _FilterMenu(value: rating, values: const {'top': 'Top Rated', '8_10': '8.0–10.0', '6_8': '6.0–8.0', '4_6': '4.0–6.0', '1_4': '1.0–4.0'}, onChanged: (value) => setState(() => rating = value))),
                      SizedBox(width: 150, child: _FilterMenu(value: time, values: const {'all': 'All Time', 'latest': 'Latest → Oldest', 'oldest': 'Oldest → Latest'}, onChanged: (value) => setState(() => time = value))),
                      SizedBox(width: 170, child: _FilterMenu(value: language, values: const {'all': 'All Languages', 'en': 'English', 'hi': 'Hindi', 'ta': 'Tamil', 'te': 'Telugu', 'ml': 'Malayalam', 'kn': 'Kannada', 'bn': 'Bengali', 'mr': 'Marathi', 'pa': 'Punjabi', 'gu': 'Gujarati', 'ko': 'Korean', 'ja': 'Japanese', 'zh': 'Chinese', 'es': 'Spanish', 'fr': 'French', 'de': 'German', 'it': 'Italian', 'tr': 'Turkish', 'th': 'Thai', 'id': 'Indonesian', 'ru': 'Russian', 'ar': 'Arabic'}, onChanged: (value) => setState(() => language = value))),
                    ]),
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

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({required this.value, required this.values, required this.onChanged});
  final String value;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        key: ValueKey('listing-filter-$value'),
        value: value,
        dropdownColor: MovanaColors.card,
        decoration: InputDecoration(filled: true, fillColor: MovanaColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
        items: values.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      );
}