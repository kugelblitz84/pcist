// ignore_for_file: non_constant_identifier_names, prefer_interpolation_to_compose_strings, avoid_print
//import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:pcist/config/userConfig.dart';
import 'package:pcist/pages/eventPages/all_events.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/eventApi.dart';
import 'package:pcist/services/userApi.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/pages/authPages/passResetPage.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'dart:io';
//import 'package:path/path.dart';
//import 'package:image_picker/image_picker.dart';

class Ontapprocesses {
  static Future<void> LoginProcess(String roll, String pass) async {
    try {
      final response = await UserAPI.login(roll, pass);
      print("response: ${response.statusCode}");
      final res = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Get.snackbar('debug error',"stat code: ${statCode}"); ////////
        Get.snackbar('', res['message'] + " success : ${res['status']}");
        final token = res['token'];
        final slug = res['slug'];
        // Get.snackbar('', res['message']);
        if (res['status'] == true) {
          await Tokenprocess.storeToken(
            key: 'authToken',
            token: token,
            slug: slug,
          );
          await UserConfig.initialiseUser();
          // ever(UserConfig.isSignedIn, (bool signedIn) {
          //   if (signedIn) {
          //     Get.offNamed('/dashBoard');
          //   }
          // });

          await Get.offNamed('/');

          // final dataResponse = await UserAPI.getUserData(slug);
          // final data = jsonDecode(dataResponse.body);
          // if (dataResponse.statusCode == 200) {
          //   UserAPI.SetUserDatafromJson(data);
          //   //final t = await Tokenprocess.readToken();
          //   //print(t['token']);
          //   //print(t['slug']);
          //   //print("ontap process ended read token call ended");
          //   Get.offNamed('/dashBoard');
          // } else {
          //   //ignore: prefer_interpolation_to_compose_strings;
          //   Get.snackbar('', "Loading data error: " + data['message']);
          // }
        }
      } else {
        Get.snackbar('', res['message']);
      }
    } catch (e) {
      Get.snackbar('debug error', "error in the ontap class $e");
    }
  }

  static Future<dynamic> SignupProcess(
    String email,
    String pass,
    String roll,
  ) async {
    //registration request
    final response = await UserAPI.register(roll, email, pass);
    final res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // Get.snackbar(
      //   'ontap class: ',
      //   res['message'] + ' ' + res['status'].toString(),
      // );
      //Get.snackbar('status: ', res['status']);
      if (res['status'] == true) {
        //registration successfull , now verify email using otp and store token
        final token = res['token'];
        final slug = res['slug'];
        await Tokenprocess.storeToken(
          key: 'authToken',
          token: token,
          slug: slug,
        );
        await UserAPI.SetUserDatafromJson({'classroll': roll, 'email': email});
        await UserAPI.sendVerificationMail(token, slug);
        //print('something went wrong here');
        Get.toNamed(
          '/OtpPage',
        ); //get to the otp page to receive the code from user and verify
      }
    } else {
      Get.snackbar('', res['message']);
    }
  }

  static Future<dynamic> VerifyOtpProcess(String code) async {
    try {
      final secureData = await Tokenprocess.readToken();
      final token = secureData['authToken'] ?? "",
          slug = secureData['slug'] ?? "";
      //print("ontap process class slug: $slug");
      final response = await UserAPI.verifyOTP(code, token, slug);
      final res = jsonDecode(response.body);
      Get.snackbar('', res['message']);
      if (response.statusCode == 200) {
        Get.toNamed('/takeUserDetails');
      }
    } catch (e) {
      Get.snackbar(
        'debug error',
        "error in the verifyOTP in the ontap process class: $e",
      );
    }
  }

  static Future<dynamic> setUserDetails({
    required String name,
    required String phone,
    required String gender,
    required String shirt,
    required String batch,
    required String dept,
    required String cfhandle,
    required String atchandle,
    required String cchandle,
    required String slug,
    required String token,
  }) async {
    try {
      final response = await UserAPI.updateUserProfile(
        token: token,
        name: name,
        phone: phone,
        gender: gender,
        tshirt: shirt,
        batch: batch,
        dept: dept,
        cfhandle: cfhandle,
        atchandle: atchandle,
        cchandle: cchandle,
        slug: slug,
      );

      final res = jsonDecode(response.body);
      //print("response: $res");
      Get.snackbar('', res['message']);
      if (res['status'] == true) {
        //Get.snackbar('debug error', '✅ ${res['message']}');
        UserAPI.SetUserDatafromJson({
          'classroll':
              LoggedInUserData.classroll, //set during the signup process.
          'email': LoggedInUserData.email, //set during the signup process.
          'phone': phone,
          'name': name,
          'gender': gender,
          'tshirt': shirt,
          'batch': batch,
          'dept': dept,
          'cfhandle': cfhandle,
          'atchandle': atchandle,
          'cchandle': cchandle,
        });
      } else {
        Get.snackbar('debug error', '⚠️ Failed: ${res['message']}');
      }
    } catch (e) {
      Get.snackbar('debug error', "error in the ontap class ${e.toString()}");
    }
  }

  static Future<void> sendForGotPassMail({required String mail}) async {
    try {
      final res = await UserAPI.sendPassResetMail(mail: mail);
      final response = jsonDecode(res.body);

      if (res.statusCode == 200) {
        Get.snackbar('Success', response['message']);
        Get.off(setNewPassPage());
      } else {
        Get.snackbar('Failed!', response['message']);
      }
    } catch (e) {
      Get.snackbar('Unknown Error', e.toString());
    }
  }

  static Future<dynamic> logOut() async {
    try {
      await Tokenprocess.eraseToken();
      await UserConfig.logOutUser();
      Get.offAllNamed('/');
    } catch (e) {
      return e;
    }
  }

  // static Future<File?> pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   return pickedFile != null ? File(pickedFile.path) : null;
  // }
  static Future<void> setNewPass({
    required String mail,
    required String code,
    required,
    required String newPass,
  }) async {
    try {
      final res = await UserAPI.setNewPass(
        mail: mail,
        code: code,
        newPass: newPass,
      );
      final response = jsonDecode(res.body);
      String title = res.statusCode == 200 ? 'Success' : 'Failed';
      Get.snackbar(title, response['message']);
      if (title == 'Success') {
        Get.until((route) => Get.currentRoute == '/login');
        //Get.offNamed('/login');
      }
    } catch (e) {
      print("Error in the ontap class while setting new password: $e");
    }
  }

  static Future<void> UpdateUserProfile({
    required String? token,
    required String? slug,
    required String name,
    required String phone,
    required String gender,
    required String tshirt,
    required String batch,
    required String dept,
    required String cfhandle,
    required String atchandle,
    required String cchandle,
  }) async {
    try {
      final response = await UserAPI.updateUserProfile(
        token: token ?? "",
        name: name,
        phone: phone,
        gender: gender,
        tshirt: tshirt,
        batch: batch,
        dept: dept,
        cfhandle: cfhandle,
        atchandle: atchandle,
        cchandle: cchandle,
        slug: slug ?? "21060",
      );
      if (response == null) {
        print("error in response");
        return;
      }
      final data = jsonDecode(response.body);
      if (data['code'] == 200) {
        UserConfig.initialiseUser();
        Get.snackbar("Success", "Updated profile successfully");
      } else {
        Get.snackbar("Error", "could not update profile");
      }
    } catch (e) {
      print("Eror in the ontap class $e");
    }
  }

  static Future<void> addEvent(
    String eventName,
    String eventType,
    String date,
    String location,
    String description,
    List<File?> images,
    bool needMemberShip,
    String registrationDeadline, // ✅ New parameter
  ) async {
    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'], slug = tokenData['slug'];

      final response = await EventApi.addEvent(
        eventName: eventName,
        eventType: eventType,
        date: date,
        location: location,
        description: description,
        imageFiles: images,
        token: token ?? "",
        slug: slug ?? "",
        needMemberShip: needMemberShip,
        registrationDeadline: registrationDeadline, // ✅ Sent to API
      );

      final res = jsonDecode(response.body);
      print(response.statusCode);
      print(res['message']);
      if (response.statusCode == 200) {
        Get.snackbar("Success", res['message']);
      } else {
        Get.snackbar("Failed", res['message']);
      }
    } catch (e) {
      Get.snackbar("Ontap class Error: ", "$e");
      print("$e");
    }
  }

  static Future<void> registerForEvent(
    String eventId,
    Map<String, dynamic> data,
    String eventType,
  ) async {
    try {
      final response = await EventApi.registerForEvents(
        eventId,
        data,
        eventType,
      );
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Registration successful');
      } else {
        final responseBody = json.decode(response.body);
        Get.snackbar('Error', responseBody['message'] ?? 'Registration failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    }
  }

  static Future<void> deleteEvent({required String id}) async {
    try {
      final response = await EventApi.deleteEvent(id: id);
      Get.back();
      Get.back();

      if (response.statusCode == 200) {
        Get.snackbar("Success!", "event deleted successfully");
        await Eventsconfig.initializeEvents();
        Get.off(AllEventsPage());
      } else if (response.statusCode == 404) {
        Get.snackbar("Failed!", "Event not found");
      } else {
        throw (response.statusCode);
      }
    } catch (err) {
      print("Error in the ontap class: $err");
    }
  }

  static Future<void> UploadToGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      //List<File> images = [];
      if (pickedFiles.isNotEmpty) {
        final images = pickedFiles.map((image) => File(image.path)).toList();
        if (images.isNotEmpty) {
          //print("$images, $pickedFiles");
          final response = await EventApi.uploadImagesToGallery(images);
          if (response.statusCode == 200) {
            Get.snackbar("Success", "Uploaded  images to gallery");
          } else {
            print(response.statusCode);
            Get.snackbar("Failed!", "Something went wrong");
          }
        } else {
          print("images empty");
        }
      } else {
        print("picked files empty");
      }
    } catch (err) {
      print("error in the ontap class: $err");
    }
  }
}
