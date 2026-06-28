import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/movana_app.dart';
import 'core/services/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.initialize();
  runZonedGuarded(
    () => runApp(const ProviderScope(child: MovanaApp())),
    FirebaseCrashlytics.instance.recordError,
  );
}