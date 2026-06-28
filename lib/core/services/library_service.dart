import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../models/user_profile.dart';
import 'analytics_service.dart';
import 'auth_service.dart';
import 'firestore_schema_service.dart';

class LibraryState {
  const LibraryState({this.watchlist = const {}, this.watched = const {}, this.requiresSignIn = false, this.isLoading = true});

  final Set<String> watchlist;
  final Set<String> watched;
  final bool requiresSignIn;
  final bool isLoading;

  LibraryState copyWith({Set<String>? watchlist, Set<String>? watched, bool? requiresSignIn, bool? isLoading}) {
    return LibraryState(
      watchlist: watchlist ?? this.watchlist,
      watched: watched ?? this.watched,
      requiresSignIn: requiresSignIn ?? this.requiresSignIn,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LibraryController extends StateNotifier<LibraryState> {
  LibraryController({required UserProfile? user, FirebaseFirestore? firestore})
      : _user = user,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const LibraryState()) {
    _bind();
  }

  final UserProfile? _user;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _watchlistSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _watchedSubscription;

  bool get _canWrite => _user != null && !_user!.isGuest;

  Future<bool> toggleWatchlist(Movie movie) async {
    if (!_canWrite) {
      state = state.copyWith(requiresSignIn: true);
      return false;
    }
    final updated = {...state.watchlist};
    final ref = _firestore.collection(FirestoreCollections.watchlist).doc('${_user!.id}_${movie.id}');
    if (updated.contains(movie.id)) {
      updated.remove(movie.id);
      await ref.delete();
      await analyticsServiceProviderInstance.track('watchlist_remove', parameters: {'movie_id': movie.id});
    } else {
      updated.add(movie.id);
      await ref.set({
        'userID': _user.id,
        'movieID': movie.id,
        'addedAt': FieldValue.serverTimestamp(),
        'title': movie.title,
        'contentType': movie.contentType.name,
      }, SetOptions(merge: true));
      await analyticsServiceProviderInstance.track('watchlist_add', parameters: {'movie_id': movie.id});
    }
    state = state.copyWith(watchlist: updated);
    return true;
  }

  Future<bool> toggleWatched(Movie movie) async {
    if (!_canWrite) {
      state = state.copyWith(requiresSignIn: true);
      return false;
    }
    final updated = {...state.watched};
    final ref = _firestore.collection(FirestoreCollections.watched).doc('${_user!.id}_${movie.id}');
    if (updated.contains(movie.id)) {
      updated.remove(movie.id);
      await ref.delete();
    } else {
      updated.add(movie.id);
      await ref.set({
        'userID': _user.id,
        'movieID': movie.id,
        'watchedAt': FieldValue.serverTimestamp(),
        'title': movie.title,
        'runtimeMinutes': movie.runtimeMinutes,
        'rating': movie.rating,
        'genres': movie.genres,
        'providers': movie.providers,
        'director': movie.director,
        'cast': movie.cast,
        'contentType': movie.contentType.name,
      }, SetOptions(merge: true));
      await analyticsServiceProviderInstance.track('movie_marked_watched', parameters: {'movie_id': movie.id});
    }
    state = state.copyWith(watched: updated);
    return true;
  }

  void _bind() {
    if (_user == null || _user.isGuest) {
      state = const LibraryState(isLoading: false);
      return;
    }
    _watchlistSubscription = _firestore
        .collection(FirestoreCollections.watchlist)
        .where('userID', isEqualTo: _user.id)
        .snapshots()
        .listen((snapshot) {
      state = state.copyWith(
        watchlist: snapshot.docs.map((doc) => doc.data()['movieID'] as String).toSet(),
        isLoading: false,
      );
    });
    _watchedSubscription = _firestore
        .collection(FirestoreCollections.watched)
        .where('userID', isEqualTo: _user.id)
        .snapshots()
        .listen((snapshot) {
      state = state.copyWith(
        watched: snapshot.docs.map((doc) => doc.data()['movieID'] as String).toSet(),
        isLoading: false,
      );
    });
  }

  @override
  void dispose() {
    _watchlistSubscription?.cancel();
    _watchedSubscription?.cancel();
    super.dispose();
  }
}

final libraryProvider = StateNotifierProvider<LibraryController, LibraryState>((ref) {
  final user = ref.watch(authProvider);
  return LibraryController(user: user);
});