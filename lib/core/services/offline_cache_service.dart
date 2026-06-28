import 'package:shared_preferences/shared_preferences.dart';

class OfflineCacheService {
  Future<void> saveJson(String key, String payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, payload);
    await prefs.setInt('${key}_cachedAt', DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> readJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> clearExpired({Duration maxAge = const Duration(days: 1)}) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final key in prefs.getKeys().where((key) => key.endsWith('_cachedAt'))) {
      final cachedAt = prefs.getInt(key) ?? 0;
      if (now - cachedAt > maxAge.inMilliseconds) {
        final dataKey = key.replaceFirst('_cachedAt', '');
        await prefs.remove(dataKey);
        await prefs.remove(key);
      }
    }
  }
}