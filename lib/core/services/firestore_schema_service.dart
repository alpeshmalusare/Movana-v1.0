class FirestoreCollections {
  static const users = 'users';
  static const watchlist = 'watchlist';
  static const watched = 'watched';
  static const movies = 'movies';
  static const admin = 'admin';
  static const affiliateBanners = 'affiliateBanners';
}

class FirestoreSchemaService {
  Map<String, Object?> userDocument({
    required String userID,
    required String name,
    required String email,
    required String photo,
    required List<String> preferredPlatforms,
  }) {
    return {
      'userID': userID,
      'name': name,
      'email': email,
      'photo': photo,
      'createdAt': DateTime.now().toIso8601String(),
      'preferredPlatforms': preferredPlatforms,
    };
  }

  Map<String, Object?> libraryDocument({required String userID, required String movieID}) {
    return {
      'userID': userID,
      'movieID': movieID,
      'addedAt': DateTime.now().toIso8601String(),
    };
  }
}