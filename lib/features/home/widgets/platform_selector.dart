import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/movana_theme.dart';
import '../discovery_controller.dart';

class PlatformSelector extends ConsumerWidget {
  const PlatformSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(discoveryProvider).platforms;
    return SizedBox(
      key: const ValueKey('ott-platform-selector'),
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.platforms.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final platform = AppConstants.platforms[index];
          final active = selected.contains(platform);
          return InkWell(
            key: ValueKey('ott-card-$platform'),
            borderRadius: BorderRadius.circular(18),
            onTap: () => ref.read(discoveryProvider.notifier).togglePlatform(platform),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 150,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MovanaColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: active ? MovanaColors.accent : MovanaColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.play_circle_fill_rounded, color: active ? MovanaColors.accent : MovanaColors.textSecondary),
                  Text(platform, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, color: active ? Colors.white : MovanaColors.textSecondary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}