import 'package:flutter_test/flutter_test.dart';
import 'package:movana/data/demo/demo_movies.dart';

void main() {
  test('demo catalog contains movies and series', () {
    expect(demoMovies, isNotEmpty);
    expect(demoMovies.any((movie) => movie.contentType.name == 'movie'), isTrue);
    expect(demoMovies.any((movie) => movie.contentType.name == 'series'), isTrue);
  });
}