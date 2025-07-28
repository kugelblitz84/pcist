// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:pcist/secret.dart';
import 'dart:convert';

class EventApi {
  static Future<dynamic> addEvent({
    required String eventName,
    required String eventType,
    required String date, // Format: "yyyy-MM-dd"
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
      ..fields['location'] = location
      ..fields['description'] = description
      ..fields['needMembership'] = needMemberShip.toString();
    //print("number of event images : ${imageFiles.length}");
    for (int i = 0; i < imageFiles.length; i++) {
      File? file = imageFiles[i];
      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // field names
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
