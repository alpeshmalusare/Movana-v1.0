import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/movana_theme.dart';

class GenreFlowScreen extends StatelessWidget {
  const GenreFlowScreen({super.key, required this.platform, required this.providerId, required this.contentType});
  final String platform;
  final String providerId;
  final String contentType;

  static const posterBackdrops = {
    'Action': 'https://image.tmdb.org/t/p/w780/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg',
    'Adventure': 'https://image.tmdb.org/t/p/w780/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
    'Comedy': 'https://image.tmdb.org/t/p/w780/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
    'Crime': 'https://image.tmdb.org/t/p/w780/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg',
    'Drama': 'https://image.tmdb.org/t/p/w780/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg',
    'Horror': 'https://image.tmdb.org/t/p/w780/9Jf2skG4x2lVqGSSjI2qWy7fghp.jpg',
    'Mystery': 'https://image.tmdb.org/t/p/w780/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
    'Romance': 'https://image.tmdb.org/t/p/w780/8lBViysvNJBPkl6zG1LVAaW3qhj.jpg',
    'Sci-Fi': 'https://image.tmdb.org/t/p/w780/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',
    'Thriller': 'https://image.tmdb.org/t/p/w780/hiKmpZMGZsrkA3cdce8a7Dpos1j.jpg',
    'War': 'https://image.tmdb.org/t/p/w780/bQXAqRx2Fgc46uCVWgoPz5L5Dtr.jpg',
    'Western': 'https://image.tmdb.org/t/p/w780/5Lbm0gpFDRAPIV1Cth6ln9iL1ou.jpg',
  };

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
                    onTap: () => context.push('/movies', extra: {'platform': platform, 'providerId': providerId, 'type': contentType, 'genre': genre}),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MovanaColors.divider),
                        image: DecorationImage(image: NetworkImage(posterBackdrops[genre] ?? posterBackdrops['Drama']!), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(.55), BlendMode.darken)),
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