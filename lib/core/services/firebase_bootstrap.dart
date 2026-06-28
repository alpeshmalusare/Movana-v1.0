import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static Future<void> initializeIfConfigured() async {
    try {
      await Firebase.initializeApp();
    } catch (error) {
      // Firebase placeholders are intentional until project config files are added.
      debugPrint('Firebase not initialized yet: $error');
    }
  }
}