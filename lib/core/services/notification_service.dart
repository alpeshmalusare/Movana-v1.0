import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  NotificationService({FirebaseMessaging? messaging}) : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(alert: true, badge: true, sound: true, provisional: false);
  }

  Future<String?> currentToken() => _messaging.getToken();

  Future<void> subscribeToRecommendationTopics({required List<String> platforms}) async {
    await _messaging.subscribeToTopic('trending_movies');
    await _messaging.subscribeToTopic('weekend_recommendations');
    for (final platform in platforms) {
      final topic = platform.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+$'), '');
      if (topic.isNotEmpty) await _messaging.subscribeToTopic('ott_$topic');
    }
  }
}