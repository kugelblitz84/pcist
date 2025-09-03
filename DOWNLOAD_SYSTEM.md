# Dio-based Download System Documentation

## Overview

The new download system in pcIST uses **Dio** HTTP client along with **path_provider** package to provide enhanced download functionality with better error handling, progress tracking, and cross-platform file management.

## Key Features

✅ **Enhanced Error Handling**: Specific error messages for different network conditions  
✅ **Progress Tracking**: Real-time download progress with callbacks  
✅ **Cross-platform Support**: Automatically handles different download directories for Android, iOS, and desktop  
✅ **Modern UI**: Beautiful progress dialogs with material design  
✅ **Better File Management**: Organized file structure with proper directory creation  
✅ **Downloads Folder Priority**: Files are saved to easily accessible Downloads folder when possible  
✅ **Built-in PDF Viewer**: Open PDF files directly within the app using open_file package  

## Architecture

### Core Services

1. **DownloadService** (`lib/services/downloadService.dart`)
   - Low-level Dio-based download implementation
   - Handles HTTP requests, file operations, and error management
   - Provides platform-specific directory management

2. **DownloadHelper** (`lib/services/downloadHelper.dart`)
   - High-level wrapper with UI integration
   - Shows progress dialogs and success/error notifications
   - Easy-to-use methods for common download operations

## Usage Examples

### Basic PAD Statement Download

```dart
import 'package:pcist/services/downloadHelper.dart';

// Download PAD statement with progress dialog
await DownloadHelper.downloadPadStatement(
  statement: "Your statement text",
  authorizers: [
    {"name": "John Doe", "designation": "Manager"},
    {"name": "Jane Smith", "designation": "Director"}
  ],
  contactEmail: "contact@example.com",
  contactPhone: "+1234567890",
  address: "123 Main Street, City, Country",
);
```

### Download by ID

```dart
// Download existing PAD statement
await DownloadHelper.downloadPadById("pad_id_here");

// Download existing Invoice
await DownloadHelper.downloadInvoiceById("invoice_id_here");
```

### Advanced Usage with Custom Progress Handling

```dart
import 'package:pcist/services/downloadService.dart';

final result = await DownloadService.downloadPadStatement(
  statement: "Your statement",
  authorizers: authorizersList,
  contactEmail: "email@example.com",
  contactPhone: "phone",
  address: "address",
  onStart: () {
    print("Download started");
  },
  onProgress: (received, total) {
    print("Progress: ${(received / total * 100).toStringAsFixed(1)}%");
  },
  onComplete: () {
    print("Download completed");
  },
);

if (result['success']) {
  print("File saved to: ${result['filePath']}");
} else {
  print("Download failed: ${result['message']}");
}
```

## Directory Structure

The download system creates organized directory structures with priority given to Downloads folder:

### Desktop (Windows/macOS/Linux) - Primary Location
```
~/Downloads/pcIST Downloads/
├── pcIST-statement-123456789.pdf
├── INV-987654321.pdf
└── ...
```

### Android - Primary Location  
```
/storage/emulated/0/Download/pcIST/
├── pcIST-statement-123456789.pdf
├── INV-987654321.pdf
└── ...
```

### Android - Fallback Location
```
/storage/emulated/0/Android/data/com.example.pcist/files/Download/
├── pcIST-statement-123456789.pdf
├── INV-987654321.pdf
└── ...
```

### iOS - Documents Directory
```
~/Documents/Downloads/
├── pcIST-statement-123456789.pdf
├── INV-987654321.pdf
└── ...
```

### Open Downloaded File
```dart
final success = await DownloadService.openFile(filePath);
if (success) {
  print("File opened successfully");
} else {
  print("Failed to open file");
}
```

## File Management

### Get Downloaded Files
```dart
final files = await DownloadService.getDownloadedFiles();
for (final file in files) {
  print("File: ${file.path}");
}
```

### Delete Downloaded File
```dart
final success = await DownloadService.deleteDownloadedFile(filePath);
if (success) {
  print("File deleted successfully");
}
```

### Get File Size
```dart
final sizeString = DownloadService.getFileSizeString(fileSizeInBytes);
print("File size: $sizeString"); // e.g., "2.5 MB"
```

## Error Handling

The system provides specific error messages for different scenarios:

- **Connection Timeout**: "Connection timeout. Please check your internet connection."
- **Download Timeout**: "Download timeout. The file might be too large."
- **Server Error**: "Server error: 500"
- **Connection Error**: "Connection error. Please check your internet connection."

## Integration with Existing Code

### onTapProcesses.dart
The existing download methods have been updated to use the new system:

```dart
// Old method (removed)
await PadApi.downloadPadStatement(...);

// New method
await DownloadHelper.downloadPadStatement(...);
```

### History Pages
PAD and Invoice history pages now use the enhanced download system:

```dart
// PAD History
await DownloadHelper.downloadPadById(padId);

// Invoice History  
await DownloadHelper.downloadInvoiceById(invoiceId);
```

### Downloaded Documents Page
Updated to use the new DownloadService for file management:

```dart
final files = await DownloadService.getDownloadedFiles();
final directory = await DownloadService.getDownloadDirectory();
```

## Benefits Over Previous System

| Feature | Old System (HTTP) | New System (Dio + open_file) |
|---------|-------------------|-------------------------------|
| Error Handling | Basic | Comprehensive with specific messages |
| Progress Tracking | None | Real-time with callbacks |
| File Management | Manual | Automated with Downloads folder priority |
| Cross-platform | Limited | Full support with platform-specific paths |
| UI Integration | Basic snackbars | Enhanced progress dialogs + open file buttons |
| Network Resilience | Limited | Timeouts and retry logic |
| File Opening | None | Built-in PDF viewer integration |
| Downloads Location | App-specific directories | Downloads folder (easily accessible) |

## Dependencies

Make sure these packages are in your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.7.0
  open_file: ^3.3.2
  path_provider: ^2.1.5
  get: ^4.7.2
```

## Best Practices

1. **Always use DownloadHelper** for UI-integrated downloads
2. **Use DownloadService directly** only for custom implementations
3. **Handle errors gracefully** with try-catch blocks
4. **Show progress feedback** to users for better UX
5. **Test on different platforms** to ensure compatibility

## Migration Guide

To migrate from the old HTTP-based system:

1. Replace `PadApi.downloadPadStatement()` with `DownloadHelper.downloadPadStatement()`
2. Replace `InvoiceApi.downloadInvoice()` with `DownloadHelper.downloadInvoice()`
3. Remove manual file saving logic (handled automatically)
4. Update UI to use the new progress dialogs
5. Update file management to use `DownloadService` methods

The new system provides a more robust, user-friendly, and maintainable download experience across all platforms.
