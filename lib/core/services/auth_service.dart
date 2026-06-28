import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';

class AuthController extends StateNotifier<UserProfile?> {
  AuthController() : super(null);

  void continueAsGuest() {
    state = const UserProfile(
      id: 'guest',
      name: 'Guest Cinephile',
      email: 'guest@movana.local',
      photoUrl: '',
      isGuest: true,
    );
  }

  void mockGoogleSignIn() {
    state = const UserProfile(
      id: 'demo-user',
      name: 'Movana User',
      email: 'demo@movana.app',
      photoUrl: '',
      isGuest: false,
    );
  }

  void logout() => state = null;
}

final authProvider = StateNotifierProvider<AuthController, UserProfile?>((ref) => AuthController());