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
    'Action': 'https://image.tmdb.org/t/p/w780/vVpEOvdxVBP2aV166j5Xlvb5Cdc.jpg',
    'Adventure': 'https://image.tmdb.org/t/p/w780/5rrGVmRUuCKVbqUu41XIWTXJmNA.jpg',
    'Animation': 'https://image.tmdb.org/t/p/w780/xgDj56UWyeWQcxQ44f5A3RTWuSs.jpg',
    'Biography': 'https://image.tmdb.org/t/p/w780/nRgNlG3Io7B3yY9E2GFYkHcIu3x.jpg',
    'Comedy': 'https://image.tmdb.org/t/p/w780/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
    'Crime': 'https://image.tmdb.org/t/p/w780/qqHQsStV6exghCM7zbObuYBiYxw.jpg',
    'Documentary': 'https://image.tmdb.org/t/p/w780/8rIoyM6zYXJNjzGseT3MRusMPWl.jpg',
    'Drama': 'https://image.tmdb.org/t/p/w780/tsRy63Mu5cu8etL1X7ZLyf7UP1M.jpg',
    'Family': 'https://image.tmdb.org/t/p/w780/askg3SMvhqEl4OL52YuvdtY40Yb.jpg',
    'Fantasy': 'https://image.tmdb.org/t/p/w780/9BBTo63ANSmhC4e6r62OJFuK2GL.jpg',
    'History': 'https://image.tmdb.org/t/p/w780/4HWAQu28e2yaWrtupFPGFkdNU7V.jpg',
    'Horror': 'https://image.tmdb.org/t/p/w780/9Jf2skG4x2lVqGSSjI2qWy7fghp.jpg',
    'Music': 'https://image.tmdb.org/t/p/w780/5HjzYTihkH7EvOWSE7KcsF6pBMM.jpg',
    'Mystery': 'https://image.tmdb.org/t/p/w780/hiKmpZMGZsrkA3cdce8a7Dpos1j.jpg',
    'Romance': 'https://image.tmdb.org/t/p/w780/8lBViysvNJBPkl6zG1LVAaW3qhj.jpg',
    'Sci-Fi': 'https://image.tmdb.org/t/p/w780/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
    'Sport': 'https://image.tmdb.org/t/p/w780/2u7zbn8EudG6kLlBzUYqP8RyFU4.jpg',
    'Thriller': 'https://image.tmdb.org/t/p/w780/7WUHnWGx5OO145IRxPDUkQSh4C7.jpg',
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