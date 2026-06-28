import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/theme/movana_theme.dart';
import 'router.dart';

class MovanaApp extends StatefulWidget {
  const MovanaApp({super.key});

  @override
  State<MovanaApp> createState() => _MovanaAppState();
}

class _MovanaAppState extends State<MovanaApp> {
  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    FirebaseAnalytics.instance.logAppOpen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Movana',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: MovanaTheme.dark,
      routerConfig: appRouter,
    );
  }
}