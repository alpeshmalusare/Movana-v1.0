import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_dashboard_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/home/genre_flow_screen.dart';
import '../features/home/ott_selection_screen.dart';
import '../features/home/platform_home_screen.dart';
import '../features/movies/movie_details_screen.dart';
import '../features/movies/movie_listing_screen.dart';
import '../features/shell/app_shell.dart';

GoRouter buildAppRouter({required bool isAuthenticated}) => GoRouter(
  initialLocation: isAuthenticated ? '/ott' : '/login',
  observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/ott', builder: (_, __) => const OttSelectionScreen()),
    GoRoute(
      path: '/platform-home',
      builder: (_, state) {
        final extra = state.extra as Map<String, String>? ?? const {};
        return PlatformHomeScreen(platform: extra['name'] ?? 'Movana', providerId: extra['providerId'] ?? '8');
      },
    ),
    GoRoute(
      path: '/genres',
      builder: (_, state) {
        final extra = state.extra as Map<String, String>? ?? const {};
        return GenreFlowScreen(platform: extra['platform'] ?? 'Movana', providerId: extra['providerId'] ?? '8', contentType: extra['type'] ?? 'movie');
      },
    ),
    GoRoute(path: '/', builder: (_, __) => const AppShell()),
    GoRoute(
      path: '/movies',
      builder: (_, state) {
        final extra = state.extra as Map<String, String>? ?? const {};
        return MovieListingScreen(platform: extra['platform'], providerId: extra['providerId'], contentType: extra['type'], genre: extra['genre']);
      },
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (_, state) => MovieDetailsScreen(movieId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
  ],
);