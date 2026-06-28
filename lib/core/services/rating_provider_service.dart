import '../models/movie.dart';

abstract class RatingProviderService {
  Future<double> ratingFor(Movie movie);
}

class TmdbRatingProviderService implements RatingProviderService {
  const TmdbRatingProviderService();

  @override
  Future<double> ratingFor(Movie movie) async => movie.rating;
}