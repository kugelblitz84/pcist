import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/services/downloadService.dart';

class DownloadHelper {
  // Helper method to safely close progress dialog
  static void _safeCloseDialog() {
    try {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      // Ignore dialog close errors - prevents snackbar controller crashes
    }
  }

  // Helper method to show success dialog after ensuring previous dialog is closed
  static Future<void> _showSuccessDialog({
    required String title,
    required String filename,
    required String filePath,
  }) async {
    // Wait for any previous dialog to close completely
    int attempts = 0;
    while (Get.isDialogOpen == true && attempts < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    // Additional small delay to ensure UI is ready
    await Future.delayed(const Duration(milliseconds: 200));

    DownloadService.showDownloadSuccess(
      title: title,
      filename: filename,
      filePath: filePath,
    );
  }

  // Download PAD statement with progress dialog
  static Future<void> downloadPadStatement({
    required String statement,
    required List<Map<String, String>> authorizers,
    required String contactEmail,
    required String contactPhone,
    required String address,
  }) async {
    String filename =
        'pcIST-statement-${DateTime.now().millisecondsSinceEpoch}.pdf';
    bool dialogShown = false;

    try {
      // Show progress dialog
      DownloadService.showDownloadProgress(
        title: 'Downloading PAD Statement',
        filename: filename,
      );
      dialogShown = true;

      final result = await DownloadService.downloadPadStatement(
        statement: statement,
        authorizers: authorizers,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        address: address,
        onStart: () {
          // Progress dialog is already shown
        },
        onProgress: (received, total) {
          // Could update progress here if needed
        },
      );

      // Close progress dialog safely
      if (dialogShown) {
        _safeCloseDialog();
        dialogShown = false;
      }

      print("PAD download result: $result"); // Debug logging

      if (result['success']) {
        // Show success popup using helper method
        await _showSuccessDialog(
          title: 'PAD Statement downloaded successfully!',
          filename: result['filename'] ?? filename,
          filePath: result['filePath'] ?? '',
        );
      } else {
        Get.snackbar(
          "Download Failed",
          result['message'] ?? 'Unknown error occurred',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          icon: const Icon(Icons.error, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
    } catch (e) {
      // Close progress dialog safely if still open
      if (dialogShown) {
        _safeCloseDialog();
      }
      Get.snackbar(
        "Error",
        "Failed to download PAD statement: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  // Download PAD statement by ID with progress dialog
  static Future<void> downloadPadById(String id) async {
    String filename = 'pcIST-statement-$id.pdf';
    bool dialogShown = false;

    try {
      // Show progress dialog
      DownloadService.showDownloadProgress(
        title: 'Downloading PAD Statement',
        filename: filename,
      );
      dialogShown = true;

      final result = await DownloadService.downloadPadById(
        id,
        onStart: () {
          // Progress dialog is already shown
        },
        onProgress: (received, total) {
          // Could update progress here if needed
        },
      );

      // Close progress dialog safely
      if (dialogShown) {
        _safeCloseDialog();
        dialogShown = false;
      }

      print("PAD download by ID result: $result"); // Debug logging

      if (result['success']) {
        // Show success popup using helper method
        await _showSuccessDialog(
          title: 'PAD Statement downloaded successfully!',
          filename: result['filename'] ?? filename,
          filePath: result['filePath'] ?? '',
        );
      } else {
        Get.snackbar(
          "Download Failed",
          result['message'] ?? 'Unknown error occurred',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          icon: const Icon(Icons.error, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
    } catch (e) {
      // Close progress dialog safely if still open
      if (dialogShown) {
        _safeCloseDialog();
      }
      Get.snackbar(
        "Error",
        "Failed to download PAD statement: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  // Download Invoice with progress dialog
  static Future<void> downloadInvoice({
    required List<Map<String, dynamic>> products,
    required String authorizerName,
    required String authorizerDesignation,
    required String contactEmail,
    required String contactPhone,
    required String address,
  }) async {
    String filename = 'INV-${DateTime.now().millisecondsSinceEpoch}.pdf';
    bool dialogShown = false;

    try {
      // Show progress dialog
      DownloadService.showDownloadProgress(
        title: 'Downloading Invoice',
        filename: filename,
      );
      dialogShown = true;

      final result = await DownloadService.downloadInvoice(
        products: products,
        authorizerName: authorizerName,
        authorizerDesignation: authorizerDesignation,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        address: address,
        onStart: () {
          // Progress dialog is already shown
        },
        onProgress: (received, total) {
          // Could update progress here if needed
        },
      );

      // Close progress dialog safely
      if (dialogShown) {
        _safeCloseDialog();
        dialogShown = false;
      }

      print("Invoice download result: $result"); // Debug logging

      if (result['success']) {
        // Show success popup using helper method
        await _showSuccessDialog(
          title: 'Invoice downloaded successfully!',
          filename: result['filename'] ?? filename,
          filePath: result['filePath'] ?? '',
        );
      } else {
        Get.snackbar(
          "Download Failed",
          result['message'] ?? 'Unknown error occurred',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          icon: const Icon(Icons.error, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
    } catch (e) {
      // Close progress dialog safely if still open
      if (dialogShown) {
        _safeCloseDialog();
      }
      Get.snackbar(
        "Error",
        "Failed to download invoice: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }

  // Download Invoice by ID with progress dialog
  static Future<void> downloadInvoiceById(String id) async {
    String filename = 'INV-$id.pdf';
    bool dialogShown = false;

    try {
      // Show progress dialog
      DownloadService.showDownloadProgress(
        title: 'Downloading Invoice',
        filename: filename,
      );
      dialogShown = true;

      final result = await DownloadService.downloadInvoiceById(
        id,
        onStart: () {
          // Progress dialog is already shown
        },
        onProgress: (received, total) {
          // Could update progress here if needed
        },
      );

      // Close progress dialog safely
      if (dialogShown) {
        _safeCloseDialog();
        dialogShown = false;
      }

      print("Invoice download result: $result"); // Debug logging

      if (result['success']) {
        // Show success popup using helper method
        await _showSuccessDialog(
          title: 'Invoice downloaded successfully!',
          filename: result['filename'] ?? filename,
          filePath: result['filePath'] ?? '',
        );
      } else {
        Get.snackbar(
          "Download Failed",
          result['message'] ?? 'Unknown error occurred',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
          icon: const Icon(Icons.error, color: Colors.red),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
    } catch (e) {
      // Close progress dialog safely if still open
      if (dialogShown) {
        _safeCloseDialog();
      }
      Get.snackbar(
        "Error",
        "Failed to download invoice: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
      );
    }
  }
}
