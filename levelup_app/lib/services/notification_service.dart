import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Pedir permissão no Android 13+ (necessário!)
    await _requestPermissions();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: android,
    );

    await _plugin.initialize(initSettings);
  }

  static Future<void> _requestPermissions() async {
    // ANDROID 13+: Precisa pedir manualmente a permissão
    final status = await Permission.notification.status;

    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  static Future<void> showNativeNotification(
    String title,
    String body,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Notificações',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(
      1,
      title,
      body,
      notificationDetails,
    );
  }
}
