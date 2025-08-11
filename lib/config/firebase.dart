import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseNotifications {
  static const String _notifKey = "notifications";

  static Future<void> initialize(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Subscribe to global topic
    await messaging
        .subscribeToTopic('all_users')
        .then((val) => print("Subscribed to topic for global notifications"));

    // Store FCM token
    String token = await messaging.getToken() ?? "";
    Tokenprocess.storeToken(key: 'fcmToken', token: token);

    // Foreground notification handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      String title = message.notification?.title ?? "New Notification!!";
      String body = message.notification?.body ?? "Unknown Empty message";

      // Show snackbar
      Get.snackbar(title, body, icon: const Icon(Icons.add_alert));

      // Save to SharedPreferences
      await _saveNotification(title, body);

      //print('📩 Received a message while in foreground!');
      //print('🔔 Title: $title');
      //print('📝 Body: $body');
    });

    // Background/terminated handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      String title = message.notification?.title ?? "New Notification!!";
      String body = message.notification?.body ?? "Unknown Empty message";
      await _saveNotification(title, body);
      //print('📲 App opened via notification');
    });
  }

  /// Save notification to SharedPreferences
  static Future<void> _saveNotification(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing list
    List<String> notifList = prefs.getStringList(_notifKey) ?? [];

    // Create new notification map
    Map<String, String> newNotif = {
      "title": title,
      "body": body,
      "time": DateTime.now().toIso8601String(),
    };

    // Add new notification at the start
    notifList.insert(0, jsonEncode(newNotif));

    // Keep only the latest 20
    if (notifList.length > 20) {
      notifList = notifList.sublist(0, 20);
    }

    // Save back
    await prefs.setStringList(_notifKey, notifList);

    await prefs.setBool("hasUnread", true);
  }

  /// Retrieve notifications from SharedPreferences
  static Future<List<Map<String, String>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifList = prefs.getStringList(_notifKey) ?? [];

    return notifList.map((e) {
      final Map<String, dynamic> decoded = jsonDecode(e);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    }).toList();
  }
}
