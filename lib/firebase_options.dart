import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Firebase web options are not configured for Movana.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Firebase options are configured only for Android and iOS.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBO1HfkfB-XP2T0-3tgad2nMECG5tiD788',
    appId: '1:634989467300:android:a185f34bf3a625c2c77831',
    messagingSenderId: '634989467300',
    projectId: 'movana-f578b',
    storageBucket: 'movana-f578b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAktDVYFhACyCku2OVxf6NRaJ7iDZD7hvc',
    appId: '1:634989467300:ios:bbcada46bf21a46ac77831',
    messagingSenderId: '634989467300',
    projectId: 'movana-f578b',
    storageBucket: 'movana-f578b.firebasestorage.app',
    iosBundleId: 'app.movana.discovery',
  );
}