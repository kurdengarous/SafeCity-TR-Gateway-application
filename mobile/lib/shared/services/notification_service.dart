import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> showEarthquakeNotification({
    required String location,
    required double magnitude,
    required String time,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'earthquake_channel',
      'Deprem Uyarıları',
      channelDescription: 'Deprem bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '🌍 Deprem Uyarısı',
      '$location - Büyüklük: $magnitude - $time',
      details,
    );
  }

  static Future<void> showAQIWarning({
    required String station,
    required int aqi,
    required String healthMessage,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'aqi_channel',
      'Hava Kalitesi Uyarıları',
      channelDescription: 'Hava kalitesi bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '💨 Hava Kalitesi Uyarısı',
      '$station - AQI: $aqi - $healthMessage',
      details,
    );
  }
}
