import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  
  Future<void> initialize() async {
    debugPrint("🔔 Notification Service inicializado");
  }

 
  void showLocalNotification(BuildContext context, String title, String body) {
    final snack = SnackBar(
      content: Text("🔔 $title\n$body"),
      duration: Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
