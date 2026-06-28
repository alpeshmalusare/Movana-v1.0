import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  static Future<void> initializeIfConfigured() async {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      // Firebase placeholders are intentional until project config files are added.
    }
  }
}