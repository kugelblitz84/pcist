import 'dart:io';
import 'package:pcist/services/downloadService.dart';

/// Utility class to provide information about download paths
class DownloadPathInfo {
  /// Get detailed information about where PDFs are currently being stored
  static Future<Map<String, dynamic>> getCurrentDownloadInfo() async {
    try {
      final directory = await DownloadService.getDownloadDirectory();
      final files = await DownloadService.getDownloadedFiles();

      return {
        'platform': Platform.operatingSystem,
        'downloadDirectory': directory.path,
        'directoryExists': await directory.exists(),
        'totalFiles': files.length,
        'files': files
            .map(
              (file) => {
                'name': file.path.split(Platform.pathSeparator).last,
                'fullPath': file.path,
                'size': _getFileSize(file),
                'lastModified': _getLastModified(file),
              },
            )
            .toList(),
        'actualPaths': _getExpectedPaths(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'platform': Platform.operatingSystem,
        'actualPaths': _getExpectedPaths(),
      };
    }
  }

  /// Get expected download paths for different platforms
  static Map<String, String> _getExpectedPaths() {
    return {
      'Windows': 'C:/Users/[Username]/Downloads/pcIST Downloads/',
      'macOS': '/Users/[Username]/Downloads/pcIST Downloads/',
      'Linux': '/home/[Username]/Downloads/pcIST Downloads/',
      'Android':
          '/storage/emulated/0/Download/pcIST/ (or app external storage)',
      'iOS': 'App Documents/Downloads/ (sandboxed)',
    };
  }

  static String _getFileSize(FileSystemEntity file) {
    try {
      final stat = file.statSync();
      final bytes = stat.size;
      if (bytes < 1024) return '${bytes}B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } catch (e) {
      return 'Unknown';
    }
  }

  static String _getLastModified(FileSystemEntity file) {
    try {
      final stat = file.statSync();
      final date = stat.modified;
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Print download information to console (for debugging)
  static Future<void> printDownloadInfo() async {
    final info = await getCurrentDownloadInfo();
    print('=== PDF Download Location Info ===');
    print('Platform: ${info['platform']}');
    print(
      'Download Directory: ${info['downloadDirectory'] ?? 'Error getting directory'}',
    );
    print('Directory Exists: ${info['directoryExists'] ?? false}');
    print('Total Files: ${info['totalFiles'] ?? 0}');

    if (info['files'] != null) {
      print('\nDownloaded Files:');
      for (var file in info['files']) {
        print(
          '  - ${file['name']} (${file['size']}) - ${file['lastModified']}',
        );
        print('    Full Path: ${file['fullPath']}');
      }
    }

    if (info['error'] != null) {
      print('Error: ${info['error']}');
    }

    print('\nExpected Paths by Platform:');
    final paths = info['actualPaths'] as Map<String, String>;
    paths.forEach((platform, path) {
      print('  $platform: $path');
    });
    print('===============================');
  }
}
