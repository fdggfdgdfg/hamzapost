import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_article.dart';

class CacheService {
  CacheService._(this._preferences);

  final SharedPreferences _preferences;

  static const Duration defaultTtl = Duration(minutes: 60);

  static Future<CacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService._(prefs);
  }

  String _dataKey(String key) => 'cache_feed_$key';
  String _timestampKey(String key) => 'cache_feed_ts_$key';

  Future<void> saveArticles(String key, List<NewsArticle> articles) async {
    final encoded = jsonEncode(articles.map((e) => e.toJson()).toList());
    await _preferences.setString(_dataKey(key), encoded);
    await _preferences.setString(_timestampKey(key), DateTime.now().toIso8601String());
  }

  Future<List<NewsArticle>?> loadArticles(String key, {Duration ttl = defaultTtl}) async {
    final timestampIso = _preferences.getString(_timestampKey(key));
    if (timestampIso == null) {
      return null;
    }
    final timestamp = DateTime.tryParse(timestampIso);
    if (timestamp == null) {
      await clear(key);
      return null;
    }
    if (DateTime.now().isAfter(timestamp.add(ttl))) {
      await clear(key);
      return null;
    }

    final data = _preferences.getString(_dataKey(key));
    if (data == null) {
      return null;
    }
    try {
      final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
      return decoded
          .map((item) => NewsArticle.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      await clear(key);
      return null;
    }
  }

  Future<void> clear(String key) async {
    await _preferences.remove(_dataKey(key));
    await _preferences.remove(_timestampKey(key));
  }
}
