// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';
import 'dart:convert';
import 'package:get/get.dart';

class EventApi {
  static Future<dynamic> addEvent({
    required String eventName,
    required String eventType,
    required String date, // Format: "yyyy-MM-dd"
    required String registrationDeadline,
    required String location,
    required String description,
    required List<File?> imageFiles,
    required String token,
    required String slug, // can be null
    required bool needMemberShip,
  }) async {
    final uri = Uri.http(
      Secret.siteLink,
      '/api/v1/event/add_event',
    ); // replace with actual URL
    print("event tapped toekn: $token");
    var request = http.MultipartRequest('POST', uri)
      ..headers['authorization'] = "Bearer $token"
      ..fields['slug'] = slug
      ..fields['eventName'] = eventName
      ..fields['eventType'] = eventType
      ..fields['date'] = date
      ..fields['registrationDeadline'] = registrationDeadline
      ..fields['location'] = location
      ..fields['description'] = description
      ..fields['needMembership'] = needMemberShip.toString();
    //print("number of event images : ${imageFiles.length}");
    for (int i = 0; i < imageFiles.length; i++) {
      File? file = imageFiles[i];
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // field names for multer
            file.path, //file path
            contentType: getMediaType(file.path),
            filename: path.basename(file.path),
          ),
        );
      }
    }
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (e) {
      print('❗ Error: $e');
    }
  }

  static Future<dynamic> registerForEvents(
    String eventId,
    dynamic data,
    String eventType,
  ) async {
    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'];
      data['slug'] = tokenData['slug'];
      //final eventType = data.containsKey('teamName') ? 'team' : 'solo';

      final uri = (eventType == 'solo')
          ? Uri.http(
              Secret.siteLink,
              '/api/v1/event/register_for_solo_event/$eventId',
            )
          : Uri.http(
              Secret.siteLink,
              '/api/v1/event/register_for_team_event/$eventId',
            );

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = json.encode(data);
      //print("event id: ${eventType}");
      final response = await http.post(uri, headers: headers, body: body);
      return response;
    } catch (err) {
      Get.snackbar("error", "error in the evetnApi Page: $err");
    }
  }

  static Future<Map<String, dynamic>?> getEvents() async {
    try {
      final uri = Uri.http(Secret.siteLink, '/api/v1/event/get_all_event');
      final headers = {'Content-Type': 'application/json'};

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Check and parse both soloEvents and teamEvents
        return {
          'soloEvents': decoded['soloEvents'],
          'teamEvents': decoded['teamEvents'],
          'message': decoded['message'],
        };
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print("Error in the Event API: $e");
    }
    return null;
  }

  static Future<dynamic> uploadImagesToGallery(List<File> imageFiles) async {
    try {
      final uri = Uri.http(
        Secret.siteLink,
        '/api/v1/event/upload_images_to_gallery',
      );
      var request = http.MultipartRequest("POST", uri);
      //print(imageFiles);
      // imageFiles.map(
      //   (image) async => request.files.add(
      //     await http.MultipartFile.fromPath(
      //       'images',
      //       image.path,
      //       contentType: getMediaType(image.path),
      //       filename: path.basename(image.path),
      //     ),
      //   ),
      // );
      for (int i = 0; i < imageFiles.length; i++) {
        File? file = imageFiles[i];
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // field names for multer
            file.path, //file path
            contentType: getMediaType(file.path),
            filename: path.basename(file.path),
          ),
        );
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (err) {
      print("error in the event api class: $err");
    }
  }

  static Future<dynamic> deleteEvent({required String id}) async {
    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'], slug = tokenData['slug'];
      final uri = Uri.http(Secret.siteLink, '/api/v1/event/delete_event/$id');
      final headers = {
        "Content-type": "application/json",
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({'slug': slug});
      final response = await http.post(uri, headers: headers, body: body);
      return response;
    } catch (e) {
      print("error in the event api class: $e");
    }
  }
}

MediaType getMediaType(String filePath) {
  String extension = path.extension(filePath).toLowerCase();

  switch (extension) {
    case '.jpg':
    case '.jpeg':
      return MediaType('image', 'jpeg');
    case '.png':
      return MediaType('image', 'png');
    default:
      return MediaType('image', 'jpg'); // default generic type
  }
}
