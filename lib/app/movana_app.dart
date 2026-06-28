import 'package:flutter/material.dart';

import '../core/theme/movana_theme.dart';
import 'router.dart';

class MovanaApp extends StatelessWidget {
  const MovanaApp({super.key});

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