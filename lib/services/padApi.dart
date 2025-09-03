// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';

class PadApi {
  // Send PAD statement via email
  static Future<dynamic> sendPadStatement({
    required String receiverEmail,
    required String subject,
    required String statement,
    required List<Map<String, String>> authorizers,
    required String contactEmail,
    required String contactPhone,
    required String address,
  }) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/pad/send');
    final token = await Tokenprocess.readToken();

    final body = jsonEncode({
      "receiverEmail": receiverEmail,
      "subject": subject,
      "statement": statement,
      "authorizers": authorizers,
      "contactEmail": contactEmail,
      "contactPhone": contactPhone,
      "address": address,
    });

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'Bearer ${token['token']}',
    };

    try {
      final response = await http.post(uri, headers: headers, body: body);
      print("PAD Send Response: ${response.statusCode}");
      return response;
    } catch (e) {
      print("PAD Send Error: $e");
      return e;
    }
  }

  // Download PAD statement as PDF
  static Future<Map<String, dynamic>> downloadPadStatement({
    required String statement,
    required List<Map<String, String>> authorizers,
    required String contactEmail,
    required String contactPhone,
    required String address,
  }) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/pad/download');
    final token = await Tokenprocess.readToken();

    final body = jsonEncode({
      "statement": statement,
      "authorizers": authorizers,
      "contactEmail": contactEmail,
      "contactPhone": contactPhone,
      "address": address,
    });

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'Bearer ${token['token']}',
    };

    try {
      final response = await http.post(uri, headers: headers, body: body);
      print("PAD Download Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Extract filename from Content-Disposition header
        String filename = 'pcIST-statement.pdf';
        final contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null) {
          final filenameMatch = RegExp(
            r'filename="([^"]+)"',
          ).firstMatch(contentDisposition);
          if (filenameMatch != null) {
            filename = filenameMatch.group(1) ?? filename;
          }
        }

        return {
          'success': true,
          'pdfBytes': response.bodyBytes,
          'filename': filename,
          'contentType': response.headers['content-type'] ?? 'application/pdf',
        };
      } else {
        final errorResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              errorResponse['message'] ?? 'Failed to download PAD statement',
        };
      }
    } catch (e) {
      print("PAD Download Error: $e");
      return {
        'success': false,
        'message': 'Error downloading PAD statement: $e',
      };
    }
  }

  // Download PAD statement by ID
  static Future<Map<String, dynamic>> downloadPadById(String id) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/pad/download/$id');
    final token = await Tokenprocess.readToken();

    final headers = {'authorization': 'Bearer ${token['token']}'};

    try {
      final response = await http.get(uri, headers: headers);
      print("PAD Download by ID Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Extract filename from Content-Disposition header
        String filename = 'pcIST-statement.pdf';
        final contentDisposition = response.headers['content-disposition'];
        if (contentDisposition != null) {
          final filenameMatch = RegExp(
            r'filename="([^"]+)"',
          ).firstMatch(contentDisposition);
          if (filenameMatch != null) {
            filename = filenameMatch.group(1) ?? filename;
          }
        }

        return {
          'success': true,
          'pdfBytes': response.bodyBytes,
          'filename': filename,
          'contentType': response.headers['content-type'] ?? 'application/pdf',
        };
      } else {
        final errorResponse = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorResponse['message'] ?? 'PAD statement not found',
        };
      }
    } catch (e) {
      print("PAD Download by ID Error: $e");
      return {
        'success': false,
        'message': 'Error downloading PAD statement: $e',
      };
    }
  }

  // Get PAD history
  static Future<dynamic> getPadHistory() async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/pad/history');
    final token = await Tokenprocess.readToken();

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'Bearer ${token['token']}',
    };

    try {
      final response = await http.get(uri, headers: headers);
      print("PAD History Response: ${response.statusCode}");
      return response;
    } catch (e) {
      print("PAD History Error: $e");
      return e;
    }
  }
}
