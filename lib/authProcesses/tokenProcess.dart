import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//import 'package:http/http.dart' as http;
//import 'package:pcist/secret.dart';

class Tokenprocess {
  static final _secure_storage = FlutterSecureStorage();
  static Future<void> storeToken(
      {required String key, required String token, String? slug}) async {
    _secure_storage.write(key: key, value: token);
    if (slug != null) _secure_storage.write(key: 'authSlug', value: slug);
  }

  static Future<Map<String, String>> readToken() async {
    final String token = await _secure_storage.read(key: 'authToken') ?? "";
    final String slug = await _secure_storage.read(key: 'authSlug') ?? "";
    final String fcmtoken = await _secure_storage.read(key: 'fcmToken') ?? "";
    final res = {"authToken": token, "slug": slug, "fcmToken": fcmtoken};
    return res;
  }

  static Future<void> eraseToken() async {
    await _secure_storage.deleteAll();
  }
  // static Future<dynamic> verifyToken(String token) async {
  //   final uri = Uri.http(Secret.siteLink, '')
  // }
}
