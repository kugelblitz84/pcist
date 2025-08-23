import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/config/socket.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/userApi.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:http/http.dart' as http;

class UserConfig extends GetxController {
  static RxBool isLoading = true.obs;
  static RxBool isSignedIn = false.obs;
  static RxBool chatLoaded = false.obs;
  static Timer? _retryTimer;

  @override
  void onInit() {
    super.onInit();
    //initialiseUser();
  }

  static Future<void> initialiseUser() async {
    try {
      final tokenData = await Tokenprocess.readToken();

      final response = await UserAPI.getUserData(tokenData["slug"] ?? "21010");
      await Eventsconfig.initializeEvents();
      await SocketConfig.connect();
      // print(
      //     'initalize user class response from get userdata: ${response.statusCode}');
      if (response.runtimeType == bool) {
        print('error in response');
        retryLater();
      } else if (response.statusCode == 200) {
        await UserAPI.SetUserDatafromJson(jsonDecode(response.body));
        //print("initialized userdata");
        _retryTimer?.cancel();
        isSignedIn.value = true;
        isLoading.value = false;
      } else {
        _retryTimer?.cancel();
        isSignedIn.value = false;
        isLoading.value = false;
      }
    } catch (e) {
      print('error in the initializeuser function');
      retryLater();
    }
  }

  static Future<void> fetchChats(String token, String slug) async {
    try {
      final uri = Uri.http(Secret.siteLink, '/api/v1/chat/get_chat_messages');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({'slug': slug});
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        jsonDecode(response.body);
        // Process the chat data as needed
        print('Chats fetched successfully:');
        chatLoaded.value = true;
      } else {
        print('Failed to fetch chats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chats: $e');
    }
  }

  static void retryLater() {
    if (_retryTimer == null || !_retryTimer!.isActive) {
      _retryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        print("🔁 Retrying user init...");
        initialiseUser();
      });
    }
  }

  static Future<void> logOutUser() async {
    isSignedIn.value = false;
    chatLoaded.value = false;
    // Clear global user snapshot to avoid stale role showing
    LoggedInUserData.id = null;
    LoggedInUserData.classroll = null;
    LoggedInUserData.email = null;
    LoggedInUserData.verificationCode = null;
    LoggedInUserData.isEmailVerified = false;
    LoggedInUserData.forgotPasswordCode = null;
    LoggedInUserData.phone = null;
    LoggedInUserData.profileImage = null;
    LoggedInUserData.name = null;
    LoggedInUserData.gender = null;
    LoggedInUserData.tshirt = null;
    LoggedInUserData.batch = null;
    LoggedInUserData.dept = null;
    LoggedInUserData.role = null;
    LoggedInUserData.membership = false;
    LoggedInUserData.cfhandle = null;
    LoggedInUserData.atchandle = null;
    LoggedInUserData.cchandle = null;
    LoggedInUserData.badges = [];
    LoggedInUserData.certificates = [];
  }

  @override
  void onClose() {
    _retryTimer?.cancel();
    super.onClose();
  }
}
