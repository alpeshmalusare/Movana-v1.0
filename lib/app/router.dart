import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_dashboard_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/movies/movie_details_screen.dart';
import '../features/movies/movie_listing_screen.dart';
import '../features/shell/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/', builder: (_, __) => const AppShell()),
    GoRoute(path: '/movies', builder: (_, __) => const MovieListingScreen()),
    GoRoute(
      path: '/movie/:id',
      builder: (_, state) => MovieDetailsScreen(movieId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
  ],
);