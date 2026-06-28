import 'package:cloud_firestore/cloud_firestore.dart';

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
      'createdAt': FieldValue.serverTimestamp(),
      'preferredPlatforms': preferredPlatforms,
    };
  }

  Map<String, Object?> libraryDocument({required String userID, required String movieID}) {
    return {
      'userID': userID,
      'movieID': movieID,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}