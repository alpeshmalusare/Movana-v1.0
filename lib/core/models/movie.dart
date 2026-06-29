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
    this.originalTitle = '',
    this.releaseDate = '',
    this.popularity = 0,
    this.country = '',
    this.status = '',
    this.tagline = '',
    this.whereToWatch = const [],
    this.topCast = const [],
    this.crewRoles = const {},
    this.backdrops = const [],
    this.posters = const [],
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
  final String originalTitle;
  final String releaseDate;
  final double popularity;
  final String country;
  final String status;
  final String tagline;
  final List<Map<String, String>> whereToWatch;
  final List<Map<String, String>> topCast;
  final Map<String, List<String>> crewRoles;
  final List<String> backdrops;
  final List<String> posters;

  bool get isStreaming => providers.isNotEmpty;
}