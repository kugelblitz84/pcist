import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/services/downloadService.dart';

class DownloadedDocumentsPage extends StatefulWidget {
  const DownloadedDocumentsPage({super.key});

  @override
  State<DownloadedDocumentsPage> createState() =>
      _DownloadedDocumentsPageState();
}

class _DownloadedDocumentsPageState extends State<DownloadedDocumentsPage> {
  List<FileSystemEntity> pdfFiles = [];
  bool isLoading = true;
  Directory? downloadsDirectory;

  @override
  void initState() {
    super.initState();
    _loadDownloadedDocuments();
  }

  Future<void> _loadDownloadedDocuments() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Use the DownloadService to get downloaded files
      final files = await DownloadService.getDownloadedFiles();
      final directory = await DownloadService.getDownloadDirectory();

      setState(() {
        pdfFiles = files;
        downloadsDirectory = directory;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading downloaded documents: $e");
      setState(() {
        isLoading = false;
      });
      Get.snackbar("Error", "Failed to load downloaded documents");
    }
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text('Delete Document'),
          content: Text(
            'Are you sure you want to delete ${_getFileName(file.path)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                final success = await DownloadService.deleteDownloadedFile(
                  file.path,
                );
                if (success) {
                  _loadDownloadedDocuments();
                  Get.snackbar("Success", "Document deleted successfully");
                } else {
                  Get.snackbar("Error", "Failed to delete document");
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to delete document");
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final success = await DownloadService.openFile(filePath);
      if (success) {
        // File opened successfully, no need for additional feedback
        // The system will handle opening the file with the default PDF viewer
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to open document: $e");
    }
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  String _getFileSize(FileSystemEntity file) {
    try {
      final stat = file.statSync();
      return DownloadService.getFileSizeString(stat.size);
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getFormattedDate(FileSystemEntity file) {
    try {
      final stat = file.statSync();
      final date = stat.modified;
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getDocumentType(String fileName) {
    if (fileName.toLowerCase().contains('inv-')) {
      return 'Invoice';
    } else if (fileName.toLowerCase().contains('pcist-')) {
      return 'PAD Statement';
    } else {
      return 'Document';
    }
  }

  Color _getDocumentColor(String fileName) {
    if (fileName.toLowerCase().contains('inv-')) {
      return Colors.green;
    } else if (fileName.toLowerCase().contains('pcist-')) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  IconData _getDocumentIcon(String fileName) {
    if (fileName.toLowerCase().contains('inv-')) {
      return Icons.receipt;
    } else if (fileName.toLowerCase().contains('pcist-')) {
      return Icons.description;
    } else {
      return Icons.picture_as_pdf;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Documents'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadDownloadedDocuments,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepOrange, Colors.orange],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepOrange,
                        ),
                      )
                    : pdfFiles.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Downloaded Documents',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Downloaded PDFs will appear here',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.add),
                                label: const Text('Create Documents'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.folder,
                                      color: Colors.deepOrange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Downloaded Documents',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${pdfFiles.length} document(s)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (downloadsDirectory != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'Downloads',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: Colors.deepOrange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Documents List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: pdfFiles.length,
                              itemBuilder: (context, index) {
                                final file = pdfFiles[index];
                                final fileName = _getFileName(file.path);
                                final docType = _getDocumentType(fileName);
                                final color = _getDocumentColor(fileName);
                                final icon = _getDocumentIcon(fileName);

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: InkWell(
                                    onTap: () => _openFile(file.path),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          // Document Icon
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              icon,
                                              color: color,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          // Document Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  fileName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                            vertical: 1,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: color
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              3,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        docType,
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          color: color,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        _getFileSize(file),
                                                        style: TextStyle(
                                                          fontSize: 9,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 1),
                                                Text(
                                                  'Downloaded: ${_getFormattedDate(file)}',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey[500],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Action Button
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: PopupMenuButton<String>(
                                              padding: EdgeInsets.zero,
                                              iconSize: 18,
                                              onSelected: (value) {
                                                if (value == 'open') {
                                                  _openFile(file.path);
                                                } else if (value == 'delete') {
                                                  _deleteFile(file);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'open',
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.open_in_new,
                                                        size: 16,
                                                        color: Colors.blue,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        'Open PDF',
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.delete,
                                                        size: 16,
                                                        color: Colors.red,
                                                      ),
                                                      SizedBox(width: 6),
                                                      Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              icon: const Icon(
                                                Icons.more_vert,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
