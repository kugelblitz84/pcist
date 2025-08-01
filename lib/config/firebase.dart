import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:get/get.dart';

class FirebaseNotifications {
  static Future<void> initialize(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions (especially for iOS)
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging
        .subscribeToTopic('all_users')
        .then((val) => print("subscribed to topic for global notofications"));
    // Print FCM token
    String token = await messaging.getToken() ?? "";
    //print("FCM Token: $token");
    Tokenprocess.storeToken(key: 'fcmToken', token: token);
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Get.snackbar(
        message.notification!.title ?? "New Notification!!",
        message.notification!.body ??
            "Unknown Empty message Possily for dev testing",
        icon: const Icon(Icons.add_alert),
      );
      print('📩 Received a message while in foreground!');
      if (message.notification != null) {
        print('🔔 Title: ${message.notification!.title}');
        print('📝 Body: ${message.notification!.body}');
      }
    });

    // Background & terminated message handling (optional)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 App opened via notification');
    });
  }
}
