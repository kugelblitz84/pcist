import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';

class DownloadService {
  static final Dio _dio = Dio();

  // Initialize Dio with default settings
  static void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: 'http://${Secret.siteLink}',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      headers: {'Content-Type': 'application/json'},
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
    required String statement,
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

      // Prepare headers
      final options = Options(
        headers: {
          'authorization': 'Bearer ${token['token']}',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.bytes,
      );

      // Prepare request body
      final body = {
        "statement": statement,
        "authorizers": authorizers,
        "contactEmail": contactEmail,
        "contactPhone": contactPhone,
        "address": address,
      };

      onStart?.call();

      // Make the request with progress tracking
      final response = await _dio.post(
        '/api/v1/user/pad/download',
        data: body,
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
    } on DioException catch (e) {
      String errorMessage = 'Download failed';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout. The file might be too large.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionError) {
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

  // Download PAD statement by ID
  static Future<Map<String, dynamic>> downloadPadById(
    String id, {
    Function(int, int)? onProgress,
    VoidCallback? onStart,
    VoidCallback? onComplete,
  }) async {
    _initializeDio();

    try {
      final token = await Tokenprocess.readToken();

      final options = Options(
        headers: {'authorization': 'Bearer ${token['token']}'},
        responseType: ResponseType.bytes,
      );

      onStart?.call();

      final response = await _dio.get(
        '/api/v1/user/pad/download/$id',
        options: options,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        String filename =
            'pcIST-statement-$id-${DateTime.now().millisecondsSinceEpoch}.pdf';
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
        return {'success': false, 'message': 'PAD statement not found'};
      }
    } on DioException catch (e) {
      String errorMessage = 'Download failed';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout. The file might be too large.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionError) {
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

      final options = Options(
        headers: {
          'authorization': 'Bearer ${token['token']}',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.bytes,
      );

      final body = {
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
    } on DioException catch (e) {
      String errorMessage = 'Download failed';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout. The file might be too large.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionError) {
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

      final options = Options(
        headers: {'authorization': 'Bearer ${token['token']}'},
        responseType: ResponseType.bytes,
      );

      onStart?.call();

      final response = await _dio.get(
        '/api/v1/user/invoice/download/$id',
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
    } on DioException catch (e) {
      String errorMessage = 'Download failed';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Download timeout. The file might be too large.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionError) {
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
