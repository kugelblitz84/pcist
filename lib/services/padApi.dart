// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';

class PadApi {
  // Send PAD statement via email (JSON body with plain text statement)
  static Future<http.Response> sendPadStatement({
    required String receiverEmail,
    required String statement,
    String? subject,
    List<Map<String, String>>? authorizers,
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/pad/send');
    final token = await Tokenprocess.readToken();
    final slug = token['slug'] ?? '';

    final Map<String, dynamic> bodyMap = {
      'slug': slug,
      'receiverEmail': receiverEmail,
      'statement': statement,
    };
    if (subject != null && subject.isNotEmpty) bodyMap['subject'] = subject;
    if (authorizers != null && authorizers.isNotEmpty) {
      bodyMap['authorizers'] = authorizers;
    }
    if (contactEmail != null && contactEmail.isNotEmpty) {
      bodyMap['contactEmail'] = contactEmail;
    }
    if (contactPhone != null && contactPhone.isNotEmpty) {
      bodyMap['contactPhone'] = contactPhone;
    }
    if (address != null && address.isNotEmpty) bodyMap['address'] = address;

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'Bearer ${token['authToken']}',
    };

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(bodyMap),
      );
      print("PAD Send Response: ${response.statusCode}");
      return response;
    } catch (e) {
      print("PAD Send Error: $e");
      rethrow;
    }
  }

  // Download PAD statement as PDF
  static Future<Map<String, dynamic>> downloadPadStatement({
    required File statementPdf,
    List<Map<String, String>> authorizers = const [],
    String? contactEmail,
    String? contactPhone,
    String? address,
  }) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/pad/download');
    final token = await Tokenprocess.readToken();
    final slug = token['slug'] ?? '';
    final request = http.MultipartRequest('POST', uri)
      ..headers['authorization'] = 'Bearer ${token['authToken']}'
      ..fields['slug'] = slug;

    if (authorizers.isNotEmpty) {
      request.fields['authorizers'] = jsonEncode(authorizers);
    }
    if (contactEmail != null && contactEmail.isNotEmpty) {
      request.fields['contactEmail'] = contactEmail;
    }
    if (contactPhone != null && contactPhone.isNotEmpty) {
      request.fields['contactPhone'] = contactPhone;
    }
    if (address != null && address.isNotEmpty) {
      request.fields['address'] = address;
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'statementPdf',
        statementPdf.path,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("PAD Download Response: ${response.statusCode}");

      if (response.statusCode == 200) {
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
    final token = await Tokenprocess.readToken();
    final slug = token['slug'] ?? '';
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/pad/download/$id', {
      'slug': slug,
    });

    final headers = {
      'authorization': 'Bearer ${token['authToken']}',
      'x-user-slug': slug,
    };

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
    final token = await Tokenprocess.readToken();
    final slug = token['slug'] ?? '';
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/pad/history', {
      'slug': slug,
    });

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'Bearer ${token['authToken']}',
      'x-user-slug': slug,
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
