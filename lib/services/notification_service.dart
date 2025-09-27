import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/news_article.dart';

class NotificationService {
  NotificationService._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<NotificationService> create() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await plugin.initialize(initializationSettings);
    return NotificationService._(plugin);
  }

  Future<bool> requestPermission() async {
    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestPermission();
      if (granted ?? false) {
        return true;
      }
    }

    final iosImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      final result = await iosImplementation.requestPermissions(alert: true);
      return result?.alert ?? false;
    }
    return true;
  }

  Future<void> showBreakingNews(NewsArticle article) async {
    const androidDetails = AndroidNotificationDetails(
      'breaking_news',
      'Breaking News',
      channelDescription: 'Alerts triggered for configured breaking news keywords.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(
      article.hashCode,
      article.title,
      article.snippet,
      details,
      payload: article.link,
    );
  }
}
