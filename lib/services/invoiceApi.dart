// ignore_for_file: non_constant_identifier_names, avoid_print, file_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';

class InvoiceApi {
  // Send Invoice via email
  static Future<dynamic> sendInvoice({
    required String receiverEmail,
    required String subject,
    required List<Map<String, dynamic>> products,
    required String authorizerName,
    required String authorizerDesignation,
    required String contactEmail,
    required String contactPhone,
    required String address,
  }) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/invoice/send');
    final token = await Tokenprocess.readToken();
    final slug = token['slug'] ?? '';

    final body = jsonEncode({
      "slug": slug,
      "receiverEmail": receiverEmail,
      "subject": subject,
      "products": products,
      "authorizerName": authorizerName,
      "authorizerDesignation": authorizerDesignation,
      "contactEmail": contactEmail,
      "contactPhone": contactPhone,
      "address": address,
    });

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'Bearer ${token['authToken']}',
    };

    try {
      final response = await http.post(uri, headers: headers, body: body);
      print("Invoice Send Response: ${response.statusCode}");
      return response;
    } catch (e) {
      print("Invoice Send Error: $e");
      return e;
    }
  }

  // Download Invoice as PDF
  static Future<Map<String, dynamic>> downloadInvoice({
    required List<Map<String, dynamic>> products,
    required String authorizerName,
    required String authorizerDesignation,
    required String contactEmail,
    required String contactPhone,
    required String address,
  }) async {
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/invoice/download');
    final token = await Tokenprocess.readToken();
    final slug = token['slug'] ?? '';

    final body = jsonEncode({
      "slug": slug,
      "products": products,
      "authorizerName": authorizerName,
      "authorizerDesignation": authorizerDesignation,
      "contactEmail": contactEmail,
      "contactPhone": contactPhone,
      "address": address,
    });

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'Bearer ${token['authToken']}',
    };

    try {
      final response = await http.post(uri, headers: headers, body: body);
      print("Invoice Download Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Extract filename from Content-Disposition header
        String filename = 'invoice.pdf';
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
          'message': errorResponse['message'] ?? 'Failed to download invoice',
        };
      }
    } catch (e) {
      print("Invoice Download Error: $e");
      return {'success': false, 'message': 'Error downloading invoice: $e'};
    }
  }

  // Download Invoice by ID
  static Future<Map<String, dynamic>> downloadInvoiceById(String id) async {
    final token = await Tokenprocess.readToken();
    final slug = token['slug'] ?? '';
    final uri = Uri.http(Secret.siteLink, '/api/v1/user/invoice/download/$id', {
      'slug': slug,
    });

    final headers = {
      'authorization': 'Bearer ${token['authToken']}',
      'x-user-slug': slug,
    };

    try {
      final response = await http.get(uri, headers: headers);
      print("Invoice Download by ID Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Extract filename from Content-Disposition header
        String filename = 'invoice.pdf';
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
          'message': errorResponse['message'] ?? 'Invoice not found',
        };
      }
    } catch (e) {
      print("Invoice Download by ID Error: $e");
      return {'success': false, 'message': 'Error downloading invoice: $e'};
    }
  }

  // Get Invoice history (admin-only)
  static Future<dynamic> getInvoiceHistory() async {
    try {
      final token = await Tokenprocess.readToken();
      final slug = token['slug'] ?? '';
      final uri = Uri.http(Secret.siteLink, '/api/v1/user/invoice/history', {
        'slug': slug,
      });

      final headers = {
        'Content-Type': 'application/json',
        'authorization': 'Bearer ${token['authToken']}',
        'x-user-slug': slug,
      };

      final response = await http.get(uri, headers: headers);
      print("Invoice History Response: ${response.statusCode}");
      print("Invoice History Body: ${response.body}");

      return response;
    } catch (e) {
      print("Invoice History Error: $e");
      return e;
    }
  }
}
