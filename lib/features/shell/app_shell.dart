import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/movana_theme.dart';
import '../home/home_screen.dart';
import '../theatre/my_theatre_screen.dart';
import '../watchlist/watchlist_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _screens = const [HomeScreen(), MyTheatreScreen(), WatchlistScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: _screens[_index]),
      bottomNavigationBar: NavigationBar(
        key: const ValueKey('bottom-navigation'),
        selectedIndex: _index,
        onDestinationSelected: (value) {
          if (value == 0) {
            context.go('/ott');
            return;
          }
          setState(() => _index = value);
        },
        backgroundColor: MovanaColors.card.withOpacity(.92),
        indicatorColor: MovanaColors.accent.withOpacity(.16),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.theaters_outlined), selectedIcon: Icon(Icons.theaters), label: 'My Theatre'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Watchlist'),
        ],
      ),
    );
  }
}