import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/movana_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return SafeArea(
      child: ListView(
        key: const ValueKey('profile-screen'),
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Profile', key: ValueKey('profile-title'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 22),
          Container(
            key: const ValueKey('profile-card'),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              CircleAvatar(radius: 32, backgroundColor: MovanaColors.background, child: Image.asset(AppAssets.icon, width: 34)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user?.name ?? 'Guest Cinephile', key: const ValueKey('profile-name'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(user?.email ?? 'guest@movana.local', key: const ValueKey('profile-email'), style: const TextStyle(color: MovanaColors.textSecondary))])),
            ]),
          ),
          const SizedBox(height: 22),
          SwitchListTile(key: const ValueKey('dark-theme-toggle'), value: true, onChanged: null, title: const Text('Dark Theme'), subtitle: const Text('Movana is dark-only for a premium cinema feel.')),
          _ProfileTile(keyName: 'notification-settings', icon: Icons.notifications_outlined, title: 'Notification Settings'),
          _ProfileTile(keyName: 'language-settings', icon: Icons.language_outlined, title: 'Language'),
          _ProfileTile(keyName: 'privacy-settings', icon: Icons.lock_outline, title: 'Privacy'),
          _ProfileTile(keyName: 'about-settings', icon: Icons.info_outline, title: 'About Movana'),
          _ProfileTile(keyName: 'share-settings', icon: Icons.share_outlined, title: 'Share Movana'),
          const SizedBox(height: 14),
          OutlinedButton.icon(key: const ValueKey('delete-account-button'), onPressed: () {}, icon: const Icon(Icons.delete_outline), label: const Text('Delete Account')),
          const SizedBox(height: 10),
          FilledButton.icon(
            key: const ValueKey('logout-button'),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.keyName, required this.icon, required this.title});
  final String keyName;
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => ListTile(
        key: ValueKey(keyName),
        leading: Icon(icon, color: MovanaColors.accent),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      );
}