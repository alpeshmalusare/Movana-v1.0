import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/movana_theme.dart';
import '../discovery_controller.dart';

class GenreSelector extends ConsumerWidget {
  const GenreSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(discoveryProvider).genres;
    return Wrap(
      key: const ValueKey('genre-selector-grid'),
      spacing: 10,
      runSpacing: 10,
      children: AppConstants.genres.map((genre) {
        final active = selected.contains(genre);
        return FilterChip(
          key: ValueKey('genre-chip-$genre'),
          label: Text(genre),
          selected: active,
          onSelected: (_) => ref.read(discoveryProvider.notifier).toggleGenre(genre),
          checkmarkColor: Colors.black,
          labelStyle: TextStyle(color: active ? Colors.black : MovanaColors.textSecondary, fontWeight: FontWeight.w700),
        );
      }).toList(),
    );
  }
}