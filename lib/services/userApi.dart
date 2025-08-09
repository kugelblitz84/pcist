import 'dart:convert';
//import 'dart:ffi';
import 'package:http/http.dart' as http;
// import 'package:get/get.dart';
// import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';

class UserAPI {
  static Future<dynamic> login(String classroll, String pass) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/login');
    final body = jsonEncode({"classroll": classroll, "password": pass});
    final header = {'Content-Type': 'application/json'};
    try {
      final response = await http.post(uri, headers: header, body: body);
      return response;
    } catch (e) {
      return e;
    }
  }

  static Future<dynamic> register(
    String classroll,
    String email,
    String pass,
  ) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/register');
    final body = jsonEncode({
      "classroll": classroll,
      "email": email,
      "password": pass,
    });
    final header = {'Content-Type': 'application/json'};
    try {
      print("http called");
      final response = await http.post(uri, headers: header, body: body);
      return response;
    } catch (e) {
      return e;
    }
  }

  static Future<dynamic> getUserData(String slug) async {
    final dynamic response;
    final Uri uri;
    // print("getUserdata called");

    // print("inside uri");
    uri = Uri.http(Secret.siteLink, '/api/v1/user/get-user-data');
    //print("uri made");
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({"slug": slug});

    try {
      //print("calling for response");
      response = await http.post(uri, headers: headers, body: body);
      return response;
    } catch (err) {
      print("error occured when retireving user data: $err");
      return false;
    }
  }

  static Future<dynamic> sendVerificationMail(String token, String slug) async {
    try {
      final uri = Uri.http(
        Secret.siteLink,
        '/api/v1/user/send-verification-email',
      );
      final header = {
        'Content-type': 'application/json',
        "authorization": "Bearer $token",
      };
      final body = jsonEncode({"slug": slug});
      final response = await http.post(uri, headers: header, body: body);
      return response;
    } catch (e) {
      return e;
    }
  }

  static Future<dynamic> verifyOTP(
    String code,
    String token,
    String slug,
  ) async {
    try {
      final uri = Uri.http(Secret.siteLink, '/api/v1/user/verify-user');
      final header = {
        "Content-type": "application/json",
        "authorization": "Bearer $token",
      };
      final body = jsonEncode({"code": code, "slug": slug});
      final response = http.post(uri, headers: header, body: body);
      return response;
    } catch (e) {
      print("error inside the verifyOTP in the userAPI class: $e");
    }
  }

  static Future<dynamic> sendPassResetMail({required String mail}) async {
    try {
      final uri = Uri.http(
        Secret.siteLink,
        '/api/v1/user/send-forgot-password-email',
      );
      final header = {"Content-type": "application/json"};
      final body = jsonEncode({'email': mail});
      final response = http.post(uri, headers: header, body: body);
      return response;
    } catch (e) {
      print('Internal server Error in the userAPI class : $e');
    }
  }

  static Future<dynamic> setNewPass({
    required String mail,
    required String code,
    required String newPass,
  }) async {
    try {
      final uri = Uri.http(Secret.siteLink, '/api/v1/user/recover-password');
      final header = {"Content-type": "application/json"};
      final body = jsonEncode({
        'email': mail,
        'code': code,
        'password': newPass,
      });
      final response = await http.post(uri, headers: header, body: body);
      return response;
    } catch (e) {
      print("Error in the UserAPI class when setting new pass: $e");
    }
  }

  static Future<dynamic> updateUserProfile({
    required String token, // Authorization token if needed
    required String name,
    required String phone,
    required String gender,
    required String tshirt,
    required String batch,
    required String dept,
    required String cfhandle,
    required String atchandle,
    required String cchandle,
    required String slug,
  }) async {
    final uri = Uri.http(
      Secret.siteLink,
      '/api/v1/user/update-profile',
    ); // Replace with your actual endpoint

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Remove if not needed
    };

    final body = jsonEncode({
      'slug': slug,
      'name': name,
      'phone': phone,
      'gender': gender,
      'tshirt': tshirt,
      'batch': batch,
      'dept': dept,
      'cfhandle': cfhandle,
      'atchandle': atchandle,
      'cchandle': cchandle,
    });

    try {
      final response = await http.put(uri, headers: headers, body: body);
      return response;
    } catch (e) {
      print('❌ Error in the userApi class: $e');
    }
  }

  static Future<void> SetUserDatafromJson(Map<String, dynamic> json) async {
    //String name = json['name'];
    print("user api class set user data from json called : $json");
    LoggedInUserData.id = json['_id']?.toString();
    LoggedInUserData.classroll = json['classroll']?.toString();
    LoggedInUserData.role = json['role'];
    LoggedInUserData.classroll = json['classroll']?.toString();
    LoggedInUserData.email = json['email']?.toString();
    LoggedInUserData.verificationCode = json['verificationCode']?.toString();
    LoggedInUserData.isEmailVerified = json['is_email_verified'] ?? false;
    LoggedInUserData.forgotPasswordCode = json['forgotPasswordCode']
        ?.toString();
    LoggedInUserData.phone = json['phone']?.toString();
    LoggedInUserData.profileImage = json['profileimage']?.toString();
    LoggedInUserData.name = json['name']?.toString();
    LoggedInUserData.gender = json['gender']?.toString();
    LoggedInUserData.tshirt = json['tshirt']?.toString();
    LoggedInUserData.batch = json['batch'] is int
        ? json['batch']
        : int.tryParse(json['batch']?.toString() ?? '');
    LoggedInUserData.dept = json['dept']?.toString();
    LoggedInUserData.role = json['role'] is int
        ? json['role']
        : int.tryParse(json['role']?.toString() ?? '') ?? 1;
    LoggedInUserData.membership = json['membership'] ?? false;
    LoggedInUserData.cfhandle = json['cfhandle']?.toString();
    LoggedInUserData.atchandle = json['atchandle']?.toString();
    LoggedInUserData.cchandle = json['cchandle']?.toString();

    LoggedInUserData.badges = (json['badges'] is List)
        ? List<String>.from(json['badges'].map((e) => e.toString()))
        : [];

    LoggedInUserData.certificates = (json['certificates'] is List)
        ? List<String>.from(json['certificates'].map((e) => e.toString()))
        : [];

    print("setdata complete");
  }
}
