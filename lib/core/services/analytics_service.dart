import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics}) : _analytics = analytics;

  final FirebaseAnalytics? _analytics;
  FirebaseAnalytics get _client => _analytics ?? FirebaseAnalytics.instance;

  Future<void> track(String eventName, {Map<String, Object>? parameters}) async {
    await _client.logEvent(name: eventName, parameters: parameters);
  }

  Future<void> setUserId(String? userId) => _client.setUserId(id: userId);
}

final analyticsServiceProviderInstance = AnalyticsService();