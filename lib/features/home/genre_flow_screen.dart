import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/movana_theme.dart';

class GenreFlowScreen extends StatelessWidget {
  const GenreFlowScreen({super.key, required this.platform, required this.contentType});
  final String platform;
  final String contentType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconButton(key: const ValueKey('genre-back-button'), onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
            const Text('Select Genre', key: ValueKey('genre-flow-title'), style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text('Choose a genre to explore content.', style: TextStyle(color: MovanaColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 22),
            Expanded(
              child: GridView.builder(
                key: const ValueKey('single-genre-grid'),
                itemCount: AppConstants.genres.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15),
                itemBuilder: (_, index) {
                  final genre = AppConstants.genres[index];
                  return InkWell(
                    key: ValueKey('single-genre-$genre'),
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/movies', extra: {'platform': platform, 'type': contentType, 'genre': genre}),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MovanaColors.divider),
                        gradient: LinearGradient(colors: [MovanaColors.card, Colors.black.withOpacity(.75)]),
                      ),
                      child: Text(genre.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}