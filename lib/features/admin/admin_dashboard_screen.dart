import 'package:flutter/material.dart';

import '../../core/theme/movana_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = const [
      ('Update Banners', Icons.image_outlined),
      ('Featured Movies', Icons.local_movies_outlined),
      ('Featured Collections', Icons.collections_bookmark_outlined),
      ('Send Push Notifications', Icons.campaign_outlined),
      ('Manage Affiliate Banners', Icons.link_outlined),
      ('View Analytics', Icons.analytics_outlined),
      ('Manage Advertisements', Icons.ads_click_outlined),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard', key: ValueKey('admin-title'))),
      body: ListView(
        key: const ValueKey('admin-dashboard-list'),
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            key: const ValueKey('admin-summary-card'),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: MovanaColors.card, borderRadius: BorderRadius.circular(18)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Control Centre', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text('Firebase-ready admin modules for banners, push campaigns, affiliate slots, ads, and analytics.', style: TextStyle(color: MovanaColors.textSecondary, height: 1.4)),
            ]),
          ),
          const SizedBox(height: 20),
          for (final module in modules)
            Card(
              key: ValueKey('admin-module-${module.$1}'),
              child: ListTile(
                leading: Icon(module.$2, color: MovanaColors.accent),
                title: Text(module.$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Firestore-backed configuration placeholder', style: TextStyle(color: MovanaColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}