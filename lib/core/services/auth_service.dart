import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'analytics_service.dart';
import 'firestore_schema_service.dart';
import '../models/user_profile.dart';

class AuthController extends StateNotifier<UserProfile?> {
  AuthController({FirebaseAuth? auth, FirebaseFirestore? firestore, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        super(null) {
    _subscription = _auth.authStateChanges().listen(_syncUser);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  StreamSubscription<User?>? _subscription;

  bool get isSignedIn => _auth.currentUser != null;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  Future<void> continueAsGuest() async {
    await _auth.signInAnonymously();
    await analyticsServiceProviderInstance.track('guest_login');
  }

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
    await analyticsServiceProviderInstance.track('google_login');
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    state = null;
  }

  Future<void> _syncUser(User? user) async {
    if (user == null) {
      state = null;
      return;
    }
    final profile = UserProfile(
      id: user.uid,
      name: user.displayName ?? (user.isAnonymous ? 'Guest Cinephile' : 'Movana User'),
      email: user.email ?? (user.isAnonymous ? 'anonymous@movana.local' : ''),
      photoUrl: user.photoURL ?? '',
      isGuest: user.isAnonymous,
    );
    state = profile;
    await _firestore.collection(FirestoreCollections.users).doc(user.uid).set({
      ...profile.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await analyticsServiceProviderInstance.setUserId(user.uid);
    await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthController, UserProfile?>((ref) => AuthController());