import 'package:http/http.dart' as http;
import 'package:pcist/secret.dart';
import 'dart:convert';

class notificationProcess {
  static Future<void> sendGlobalNotification({
    required String title,
    required String message,
    required String token,
    required String slug,
  }) async {
    final uri = Uri.http(
      Secret.siteLink,
      '/api/v1/notification/notify_all_users',
    );
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Replace with your server key
    };
    final body = jsonEncode({'slug': slug, 'title': title, 'message': message});
    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}
