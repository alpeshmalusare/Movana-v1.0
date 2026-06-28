enum ContentType { movie, series }

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.backdropUrl,
    required this.genres,
    required this.runtimeMinutes,
    required this.rating,
    required this.voteCount,
    required this.releaseYear,
    required this.providers,
    required this.director,
    required this.cast,
    required this.language,
    required this.ageRating,
    required this.contentType,
    this.writer = 'Editorial data pending',
    this.productionCompany = 'Studio information pending',
  });

  final String id;
  final String title;
  final String overview;
  final String posterUrl;
  final String backdropUrl;
  final List<String> genres;
  final int runtimeMinutes;
  final double rating;
  final int voteCount;
  final int releaseYear;
  final List<String> providers;
  final String director;
  final List<String> cast;
  final String language;
  final String ageRating;
  final ContentType contentType;
  final String writer;
  final String productionCompany;

  bool get isStreaming => providers.isNotEmpty;
}