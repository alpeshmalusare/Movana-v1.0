import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/movana_theme.dart';

class OttPlatform {
  const OttPlatform(this.name, this.logoText, this.color);
  final String name;
  final String logoText;
  final Color color;
}

const ottPlatforms = [
  OttPlatform('Netflix', 'N', Color(0xFFE50914)),
  OttPlatform('Prime Video', 'prime', Color(0xFF00A8E1)),
  OttPlatform('Disney+ Hotstar', 'hotstar', Color(0xFF123B91)),
  OttPlatform('JioHotstar', 'JH', Color(0xFF2F80ED)),
  OttPlatform('Sony LIV', 'LIV', Color(0xFFFFA000)),
  OttPlatform('ZEE5', 'ZEE5', Color(0xFFE91E63)),
  OttPlatform('Apple TV+', 'tv+', Color(0xFFFFFFFF)),
  OttPlatform('MX Player', 'MX', Color(0xFF2196F3)),
  OttPlatform('Aha', 'aha', Color(0xFFFF6D00)),
  OttPlatform('Sun NXT', 'sun', Color(0xFFFFB300)),
];

class OttSelectionScreen extends StatelessWidget {
  const OttSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose your\nOTT Platform', key: ValueKey('ott-title'), style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, height: 1.05)),
              const SizedBox(height: 10),
              const Text('Select your preferred platform to browse content.', key: ValueKey('ott-subtitle'), style: TextStyle(color: MovanaColors.textSecondary, fontSize: 16)),
              const SizedBox(height: 28),
              Expanded(
                child: GridView.builder(
                  key: const ValueKey('ott-platform-grid'),
                  itemCount: ottPlatforms.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 14, mainAxisSpacing: 14),
                  itemBuilder: (context, index) {
                    final platform = ottPlatforms[index];
                    return InkWell(
                      key: ValueKey('ott-platform-${platform.name}'),
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => context.push('/platform-home', extra: platform.name),
                      child: Container(
                        decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: MovanaColors.divider)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(platform.logoText, textAlign: TextAlign.center, style: TextStyle(color: platform.name == 'Apple TV+' ? Colors.white : platform.color, fontSize: 24, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text(platform.name, textAlign: TextAlign.center, style: const TextStyle(color: MovanaColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const Center(child: Text('You can change this later.', style: TextStyle(color: MovanaColors.textSecondary))),
            ],
          ),
        ),
      ),
    );
  }
}