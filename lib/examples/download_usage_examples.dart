// Enhanced Download System Usage Examples
// This file demonstrates how to use the new Dio-based download system with open_file integration

import 'package:pcist/services/downloadHelper.dart';
import 'package:pcist/services/downloadService.dart';

class DownloadUsageExamples {
  // Example 1: Simple PAD statement download
  static Future<void> downloadPadExample() async {
    await DownloadHelper.downloadPadStatement(
      statement: "Payment Authorization Document for Project XYZ",
      authorizers: [
        {"name": "John Doe", "designation": "Project Manager"},
        {"name": "Jane Smith", "designation": "Finance Director"},
      ],
      contactEmail: "finance@company.com",
      contactPhone: "+1234567890",
      address: "123 Business Street, City, State, 12345",
    );

    // This will:
    // 1. Show a progress dialog with PDF icon
    // 2. Download the file to Downloads folder
    // 3. Show success snackbar with "View Downloads" button
    // 4. Allow user to open PDF directly from the success message
  }

  // Example 2: Download existing document by ID
  static Future<void> downloadExistingPad(String padId) async {
    await DownloadHelper.downloadPadById(padId);

    // Downloads folder locations by platform:
    // Windows: ~/Downloads/pcIST Downloads/
    // macOS: ~/Downloads/pcIST Downloads/
    // Linux: ~/Downloads/pcIST Downloads/
    // Android: /storage/emulated/0/Download/pcIST/
    // iOS: ~/Documents/Downloads/
  }

  // Example 3: Open a downloaded file directly
  static Future<void> openPdfExample(String filePath) async {
    final success = await DownloadService.openFile(filePath);

    if (success) {
      // File opened successfully in default PDF app
      print("PDF opened in external app");
    } else {
      // Error occurred - user will see specific error message
      print("Failed to open PDF - check if PDF viewer is installed");
    }
  }

  // Example 4: Get all downloaded files
  static Future<void> listDownloadedFiles() async {
    final files = await DownloadService.getDownloadedFiles();
    final directory = await DownloadService.getDownloadDirectory();

    print("Download directory: ${directory.path}");
    print("Found ${files.length} PDF files:");

    for (final file in files) {
      final fileName = file.path.split('/').last;
      final stat = file.statSync();
      final size = DownloadService.getFileSizeString(stat.size);

      print("- $fileName ($size)");
    }
  }

  // Example 5: Invoice download with automatic file opening
  static Future<void> downloadAndOpenInvoice({
    required List<Map<String, dynamic>> products,
    required String authorizerName,
    required String authorizerDesignation,
    required String contactEmail,
    required String contactPhone,
    required String address,
  }) async {
    // First download the invoice
    await DownloadHelper.downloadInvoice(
      products: products,
      authorizerName: authorizerName,
      authorizerDesignation: authorizerDesignation,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      address: address,
    );

    // The success snackbar will show with options to:
    // 1. View Downloads folder
    // 2. User can tap on any file in DownloadedDocumentsPage to open it
  }

  // Example 6: Advanced usage with custom progress handling
  static Future<void> advancedDownloadExample() async {
    final result = await DownloadService.downloadPadStatement(
      statement: "Advanced PAD Statement",
      authorizers: [
        {"name": "Admin", "designation": "Administrator"},
      ],
      contactEmail: "admin@example.com",
      contactPhone: "123-456-7890",
      address: "Admin Office",
      onStart: () {
        print("Download started");
      },
      onProgress: (received, total) {
        final percentage = (received / total * 100).toStringAsFixed(1);
        print("Download progress: $percentage%");
      },
      onComplete: () {
        print("Download completed");
      },
    );

    if (result['success']) {
      print("File saved to: ${result['filePath']}");
      print(
        "File size: ${DownloadService.getFileSizeString(result['fileSize'])}",
      );

      // Automatically open the downloaded file
      await DownloadService.openFile(result['filePath']);
    }
  }
}

/*
Key Benefits of the Enhanced System:

1. Downloads Priority:
   - Files are saved to easily accessible Downloads folder
   - Platform-specific optimizations (Windows Downloads, Android Downloads, etc.)
   
2. Built-in PDF Viewer:
   - Users can open PDFs directly from the app
   - No need to manually navigate to file location
   
3. Better User Experience:
   - Progress dialogs show download status
   - Success messages include quick action buttons
   - Error messages are specific and helpful
   
4. Cross-platform Compatibility:
   - Works seamlessly on all platforms
   - Handles platform-specific file system differences
   
5. Easy Integration:
   - Simply replace old download calls with DownloadHelper methods
   - No changes needed to existing UI components
*/
