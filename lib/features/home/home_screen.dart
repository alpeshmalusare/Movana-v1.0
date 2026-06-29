import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/movana_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Image.asset(AppAssets.icon, width: 74)),
          const SizedBox(height: 34),
          const Text('Home', key: ValueKey('clean-home-title'), style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('Go to home and select platform or content type.', style: TextStyle(color: MovanaColors.textSecondary, fontSize: 18)),
          const Spacer(),
          SizedBox(width: double.infinity, height: 58, child: FilledButton(key: const ValueKey('start-platform-flow-button'), onPressed: () => context.go('/ott'), child: const Text('Choose OTT Platform'))),
          const Spacer(),
        ]),
      ),
    );
  }
}