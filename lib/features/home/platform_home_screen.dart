import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/movana_theme.dart';

class PlatformHomeScreen extends StatelessWidget {
  const PlatformHomeScreen({super.key, required this.platform, required this.providerId});
  final String platform;
  final String providerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(key: const ValueKey('platform-back-button'), onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
              Center(child: Text(platform.toUpperCase(), key: const ValueKey('platform-title'), style: const TextStyle(color: MovanaColors.accent, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 3))),
              const SizedBox(height: 28),
              TextField(
                key: const ValueKey('platform-search-field'),
                decoration: InputDecoration(hintText: 'Search movies, series, actors...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: MovanaColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 40),
              Row(children: [
                Expanded(child: _TypeCard(label: 'MOVIES', icon: Icons.movie_creation_outlined, onTap: () => context.push('/genres', extra: {'platform': platform, 'providerId': providerId, 'type': 'movie'}))),
                const SizedBox(width: 22),
                Expanded(child: _TypeCard(label: 'SERIES', icon: Icons.tv_outlined, onTap: () => context.push('/genres', extra: {'platform': platform, 'providerId': providerId, 'type': 'series'}))),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: .82,
        child: InkWell(
          key: ValueKey('content-type-$label'),
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: MovanaColors.divider)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 72), const SizedBox(height: 30), Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))])),
        ),
      );
}