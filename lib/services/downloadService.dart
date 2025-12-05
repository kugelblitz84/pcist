import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';
import 'package:http_parser/http_parser.dart';

class DownloadService {
  static final dio.Dio _dio = dio.Dio();

  // Initialize Dio with default settings
  static void _initializeDio() {
    _dio.options = dio.BaseOptions(
      baseUrl: 'http://${Secret.siteLink}',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      // Do not set global Content-Type; let FormData requests set multipart
    );
  }

  // Get the appropriate download directory based on platform
  static Future<Directory> getDownloadDirectory() async {
    Directory? directory;

    try {
      // For all platforms, try to get the Downloads directory first
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // For desktop platforms, use the Downloads directory
        directory = await getDownloadsDirectory();
        if (directory != null) {
          // Create pcIST folder in downloads
          final pcistDir = Directory('${directory.path}/pcIST Downloads');
          if (!await pcistDir.exists()) {
            await pcistDir.create(recursive: true);
          }
          return pcistDir;
        }
      }

      if (Platform.isAndroid) {
        // For Android, try to get the Downloads directory
        try {
          // Try to access the public Downloads directory
          final androidDownloads = Directory('/storage/emulated/0/Download');
          if (await androidDownloads.exists()) {
            // Create pcIST folder in Downloads
            final pcistDir = Directory('${androidDownloads.path}/pcIST');
            if (!await pcistDir.exists()) {
              await pcistDir.create(recursive: true);
            }
            return pcistDir;
          }
        } catch (e) {
          print("Could not access Android Downloads directory: $e");
        }

        // Fallback to external storage directory
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          final downloadDir = Directory('${directory.path}/Download');
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          return downloadDir;
        }
      }

      if (Platform.isIOS) {
        // For iOS, use the documents directory (Downloads folder is not accessible)
        directory = await getApplicationDocumentsDirectory();
        final downloadDir = Directory('${directory.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }

      // Final fallback to documents directory
      directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    } catch (e) {
      // Ultimate fallback to documents directory
      directory = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${directory.path}/Downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      return downloadDir;
    }
  }

  // Download PAD statement with progress tracking
  static Future<Map<String, dynamic>> downloadPadStatement({
    required File statementPdf,
    required List<Map<String, String>> authorizers,
    required String contactEmail,
    required String contactPhone,
    required String address,
    Function(int, int)? onProgress,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) async {
    _initializeDio();

    try {
      final token = await Tokenprocess.readToken();
      final slug = token['slug'] ?? '';

      // Prepare headers
      final options = dio.Options(
        headers: {
          'authorization': 'Bearer ${token['authToken']}',
          'x-user-slug': slug,
        },
        responseType: dio.ResponseType.bytes,
      );

      // Build multipart/form-data exactly as backend expects
      final formData = dio.FormData.fromMap({
        'statementPdf': await dio.MultipartFile.fromFile(
          statementPdf.path,
          filename: 'statement.pdf',
          contentType: MediaType('application', 'pdf'),
        ),
        'slug': slug,
        if (authorizers.isNotEmpty) 'authorizers': jsonEncode(authorizers),
        if (contactEmail.isNotEmpty) 'contactEmail': contactEmail,
        if (contactPhone.isNotEmpty) 'contactPhone': contactPhone,
        if (address.isNotEmpty) 'address': address,
      });

      onStart?.call();

      // Make the request with progress tracking
      final response = await _dio.post(
        '/api/v1/user/pad/download',
        data: formData,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        // Extract filename from Content-Disposition header
        String filename =
            'pcIST-statement-${DateTime.now().millisecondsSinceEpoch}.pdf';
        final contentDisposition =
            response.headers['content-disposition']?.first;
        if (contentDisposition != null) {
          final filenameMatch = RegExp(
            r'filename="([^"]+)"',
          ).firstMatch(contentDisposition);
          if (filenameMatch != null) {
            filename = filenameMatch.group(1) ?? filename;
          }
        }

        // Get download directory and save file
        final directory = await getDownloadDirectory();
        final file = File('${directory.path}/$filename');

        // Write file
        await file.writeAsBytes(response.data);

        onComplete?.call();

        return {
          'success': true,
          'filePath': file.path,
          'filename': filename,
          'fileSize': response.data.length,
          'directory': directory.path,
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to download PAD statement. Status: ${response.statusCode}',
        };
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Download failed';

      if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout. The file might be too large.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        final respData = e.response?.data;
        if (respData is Map && respData['message'] != null) {
          errorMessage = respData['message'].toString();
        } else {
          errorMessage = 'Server error: ${e.response?.statusCode}';
        }
      } else if (e.type == dio.DioExceptionType.connectionError) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      }

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error occurred while downloading',
        'error': e.toString(),
      };
    }
  }

  static String generatePadFilename({String? defaultName, String? pdfUrl}) {
    final effectiveDefault = defaultName?.trim().isNotEmpty == true
        ? defaultName!.trim()
        : _filenameFromUrl(pdfUrl ?? '') ??
              'pcIST-statement-${DateTime.now().millisecondsSinceEpoch}';
    return _normalisePdfFilename(effectiveDefault);
  }

  // Download PAD statement using backend route
  static Future<Map<String, dynamic>> downloadPadById(
    String id, {
    String? preferredFileName,
    Function(int, int)? onProgress,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) async {
    _initializeDio();

    try {
      final token = await Tokenprocess.readToken();
      final slug = token['slug'] ?? '';

      final options = dio.Options(
        headers: {
          'authorization': 'Bearer ${token['authToken']}',
          'x-user-slug': slug,
        },
        responseType: dio.ResponseType.bytes,
      );

      onStart?.call();

      final response = await _dio.get<List<int>>(
        '/api/v1/user/pad/download/$id?slug=$slug',
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        final defaultName =
            preferredFileName ??
            'pcIST-statement-$id-${DateTime.now().millisecondsSinceEpoch}';
        final fallbackName = generatePadFilename(defaultName: defaultName);

        final headerFilename = _extractFilenameFromContentDisposition(
          response.headers['content-disposition']?.first,
        );

        final resolvedFilename = headerFilename != null
            ? generatePadFilename(defaultName: headerFilename)
            : fallbackName;

        final bytes = _asBytes(response.data);
        final directory = await getDownloadDirectory();
        final file = File('${directory.path}/$resolvedFilename');
        await file.writeAsBytes(bytes, flush: true);

        onComplete?.call();

        return {
          'success': true,
          'filePath': file.path,
          'filename': resolvedFilename,
          'fileSize': bytes.length,
          'directory': directory.path,
        };
      }

      final statusCode = response.statusCode;
      return {
        'success': false,
        'message':
            'PAD statement download failed (HTTP ${statusCode ?? 'unknown'}).',
        'statusCode': statusCode,
      };
    } on dio.DioException catch (e) {
      String errorMessage = 'Download failed';
      final statusCode = e.response?.statusCode;

      if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout. The file might be too large.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        if (statusCode == 404) {
          errorMessage = 'PAD statement not found (404).';
        } else if (statusCode != null) {
          errorMessage = 'Server error: $statusCode';
        } else {
          errorMessage = 'Unexpected server response.';
        }
      } else if (e.type == dio.DioExceptionType.connectionError) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      }

      return {
        'success': false,
        'message': errorMessage,
        'statusCode': statusCode,
        'error': e.toString(),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error occurred while downloading',
        'error': e.toString(),
      };
    }
  }

  static String? _extractFilenameFromContentDisposition(String? header) {
    if (header == null || header.isEmpty) {
      return null;
    }

    final utf8Match = RegExp(r"filename\*=UTF-8''([^;]+)").firstMatch(header);
    if (utf8Match != null) {
      return Uri.decodeFull(utf8Match.group(1)!);
    }

    final quotedMatch = RegExp(r'filename="?([^";]+)"?').firstMatch(header);
    if (quotedMatch != null) {
      return quotedMatch.group(1);
    }

    return null;
  }

  static String? _filenameFromUrl(String url) {
    if (url.isEmpty) {
      return null;
    }
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isEmpty) {
        return null;
      }
      final segment = uri.pathSegments.last;
      if (segment.isEmpty) {
        return null;
      }
      return Uri.decodeComponent(segment);
    } catch (_) {
      return null;
    }
  }

  static String _normalisePdfFilename(String input) {
    var filename = input.trim();
    if (filename.isEmpty) {
      filename = 'pcIST-statement-${DateTime.now().millisecondsSinceEpoch}';
    }

    filename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]+'), '_');
    filename = filename.replaceAll(RegExp(r'\s+'), '_');

    if (!filename.toLowerCase().endsWith('.pdf')) {
      filename = '$filename.pdf';
    }

    return filename;
  }

  static List<int> _asBytes(dynamic data) {
    if (data == null) {
      return <int>[];
    }
    if (data is Uint8List) {
      return data;
    }
    if (data is List<int>) {
      return data;
    }
    if (data is List<dynamic>) {
      return data.cast<int>();
    }
    throw ArgumentError(
      'Unsupported download payload type: ${data.runtimeType}',
    );
  }

  // Download Invoice with progress tracking

  // Download Invoice with progress tracking
  static Future<Map<String, dynamic>> downloadInvoice({
    required List<Map<String, dynamic>> products,
    required String authorizerName,
    required String authorizerDesignation,
    required String contactEmail,
    required String contactPhone,
    required String address,
    Function(int, int)? onProgress,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) async {
    _initializeDio();

    try {
      final token = await Tokenprocess.readToken();
      final slug = token['slug'] ?? '';

      final options = dio.Options(
        headers: {
          'authorization': 'Bearer ${token['authToken']}',
          'Content-Type': 'application/json',
        },
        responseType: dio.ResponseType.bytes,
      );

      final body = {
        "slug": slug,
        "products": products,
        "authorizerName": authorizerName,
        "authorizerDesignation": authorizerDesignation,
        "contactEmail": contactEmail,
        "contactPhone": contactPhone,
        "address": address,
      };

      onStart?.call();

      final response = await _dio.post(
        '/api/v1/user/invoice/download',
        data: body,
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        String filename = 'INV-${DateTime.now().millisecondsSinceEpoch}.pdf';
        final contentDisposition =
            response.headers['content-disposition']?.first;
        if (contentDisposition != null) {
          final filenameMatch = RegExp(
            r'filename="([^"]+)"',
          ).firstMatch(contentDisposition);
          if (filenameMatch != null) {
            filename = filenameMatch.group(1) ?? filename;
          }
        }

        final directory = await getDownloadDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(response.data);

        onComplete?.call();

        return {
          'success': true,
          'filePath': file.path,
          'filename': filename,
          'fileSize': response.data.length,
          'directory': directory.path,
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to download invoice. Status: ${response.statusCode}',
        };
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Download failed';

      if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout. The file might be too large.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      }

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error occurred while downloading',
        'error': e.toString(),
      };
    }
  }

  // Download Invoice by ID
  static Future<Map<String, dynamic>> downloadInvoiceById(
    String id, {
    Function(int, int)? onProgress,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) async {
    _initializeDio();

    try {
      final token = await Tokenprocess.readToken();
      final slug = token['slug'] ?? '';

      final options = dio.Options(
        headers: {
          'authorization': 'Bearer ${token['authToken']}',
          'x-user-slug': slug,
        },
        responseType: dio.ResponseType.bytes,
      );

      onStart?.call();
      final response = await _dio.get(
        '/api/v1/user/invoice/download/$id?slug=$slug',
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        String filename =
            'INV-$id-${DateTime.now().millisecondsSinceEpoch}.pdf';
        final contentDisposition =
            response.headers['content-disposition']?.first;
        if (contentDisposition != null) {
          final filenameMatch = RegExp(
            r'filename="([^"]+)"',
          ).firstMatch(contentDisposition);
          if (filenameMatch != null) {
            filename = filenameMatch.group(1) ?? filename;
          }
        }

        final directory = await getDownloadDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(response.data);

        onComplete?.call();

        return {
          'success': true,
          'filePath': file.path,
          'filename': filename,
          'fileSize': response.data.length,
          'directory': directory.path,
        };
      } else {
        return {'success': false, 'message': 'Invoice not found'};
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Download failed';

      if (e.type == dio.DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout. The file might be too large.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        errorMessage =
            'Connection error. Please check your internet connection.';
      }

      return {'success': false, 'message': errorMessage, 'error': e.toString()};
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error occurred while downloading',
        'error': e.toString(),
      };
    }
  }

  // Show enhanced download progress dialog
  static void showDownloadProgress({
    required String title,
    required String filename,
  }) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.download, color: Colors.deepOrange, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        filename,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                minHeight: 6,
              ),
              const SizedBox(height: 12),
              Text(
                "Downloading PDF file...",
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Show download success popup dialog
  static void showDownloadSuccess({
    required String title,
    required String filename,
    required String filePath,
    bool showBackButton = false,
  }) {
    print(
      "Showing download success dialog for: $filename at $filePath",
    ); // Debug logging

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 8),
            Text(
              'Download Complete',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filename,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "File saved to Downloads folder",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: Text(
              'Close',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Get.back(); // Close dialog first
              await openFile(filePath);
            },
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Open File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Get.back(); // Close dialog
              Get.toNamed("/downloadedDocuments");
            },
            icon: const Icon(Icons.folder_open, size: 16),
            label: const Text('View Downloads'),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
          ),
          if (showBackButton)
            TextButton.icon(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to previous page
              },
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
            ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  // Get all downloaded files
  static Future<List<FileSystemEntity>> getDownloadedFiles() async {
    try {
      final directory = await getDownloadDirectory();

      if (await directory.exists()) {
        final files = directory
            .listSync()
            .where((file) => file.path.toLowerCase().endsWith('.pdf'))
            .toList();

        // Sort files by modification date (newest first)
        files.sort((a, b) {
          final statA = a.statSync();
          final statB = b.statSync();
          return statB.modified.compareTo(statA.modified);
        });

        return files;
      }

      return [];
    } catch (e) {
      print("Error getting downloaded files: $e");
      return [];
    }
  }

  // Delete a downloaded file
  static Future<bool> deleteDownloadedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print("Error deleting file: $e");
      return false;
    }
  }

  // Get file size in human readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Open file using the open_file package
  static Future<bool> openFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        Get.snackbar(
          "Error",
          "File not found. It may have been moved or deleted.",
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          icon: const Icon(Icons.error, color: Colors.red),
        );
        return false;
      }

      final result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        return true;
      } else {
        String errorMessage;
        switch (result.type) {
          case ResultType.noAppToOpen:
            errorMessage =
                "No app found to open PDF files. Please install a PDF viewer.";
            break;
          case ResultType.permissionDenied:
            errorMessage = "Permission denied. Please allow file access.";
            break;
          case ResultType.fileNotFound:
            errorMessage = "File not found. It may have been moved or deleted.";
            break;
          default:
            errorMessage = "Failed to open file: ${result.message}";
        }

        Get.snackbar(
          "Cannot Open File",
          errorMessage,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange[800],
          icon: const Icon(Icons.warning, color: Colors.orange),
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to open file: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
      );
      return false;
    }
  }
}
