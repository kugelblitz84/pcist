import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/invoiceApi.dart';
import 'package:pcist/services/downloadHelper.dart';

class InvoiceHistoryPage extends StatefulWidget {
  const InvoiceHistoryPage({super.key});

  @override
  State<InvoiceHistoryPage> createState() => _InvoiceHistoryPageState();
}

class _InvoiceHistoryPageState extends State<InvoiceHistoryPage> {
  List<Invoice> invoices = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInvoiceHistory();
  }

  Future<void> _loadInvoiceHistory() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await InvoiceApi.getInvoiceHistory();

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);

          // Validate response structure
          if (data == null || data is! Map<String, dynamic>) {
            throw FormatException('Invalid response format');
          }

          if (data['success'] == true) {
            final List<dynamic> invoiceData = data['data'] ?? [];

            setState(() {
              invoices = invoiceData
                  .map((invoice) => Invoice.fromMap(invoice))
                  .toList();
              isLoading = false;
            });
          } else {
            setState(() {
              errorMessage =
                  data['message'] ?? 'Failed to load invoice history';
              isLoading = false;
            });
          }
        } catch (jsonError) {
          setState(() {
            errorMessage = 'Failed to parse server response: $jsonError';
            isLoading = false;
          });
        }
      } else {
        final responseBody = response.body.isNotEmpty
            ? response.body
            : 'No response data';
        setState(() {
          errorMessage = 'Server error (${response.statusCode}): $responseBody';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Invoice History Error: $e'); // For debugging
      setState(() {
        if (e.toString().contains('FormatException')) {
          errorMessage = 'Invalid data format received from server';
        } else if (e.toString().contains('SocketException')) {
          errorMessage =
              'Network connection error. Please check your internet connection.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Request timeout. Please try again.';
        } else {
          errorMessage = 'An unexpected error occurred: ${e.toString()}';
        }
        isLoading = false;
      });
    }
  }

  Future<void> _downloadInvoiceById(String id) async {
    try {
      // Use the new Dio-based download helper
      await DownloadHelper.downloadInvoiceById(id);
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice History'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _loadInvoiceHistory(),
            icon: const Icon(Icons.refresh),
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
        child: Container(
          margin: const EdgeInsets.all(16),
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
          child: isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                )
              : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _loadInvoiceHistory(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : invoices.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No invoices found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first invoice to see it here.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final invoice = invoices[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepOrange,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          invoice.serial ?? 'N/A',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: invoice.sentViaEmail == true
                                              ? Colors.green
                                              : Colors.grey,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          invoice.sentViaEmail == true
                                              ? 'SENT'
                                              : 'DRAFT',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${invoice.authorizerName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '৳${invoice.grandTotal?.toStringAsFixed(2) ?? '0.00'}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    invoice.authorizerDesignation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (invoice.products.isNotEmpty) ...[
                                    const Text(
                                      'Products/Services:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...invoice.products
                                        .take(2)
                                        .map(
                                          (product) => Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            child: Text(
                                              '• ${product.description} (${product.quantity}x ৳${product.unitPrice.toStringAsFixed(2)})',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                    if (invoice.products.length > 2)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          '... and ${invoice.products.length - 2} more items',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                  ],
                                  Row(
                                    children: [
                                      if (invoice.receiverEmail != null &&
                                          invoice.receiverEmail!.isNotEmpty)
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.email,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  invoice.receiverEmail!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      if (invoice.dateStr != null)
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              invoice.dateStr!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _downloadInvoiceById(invoice.id!),
                                        icon: const Icon(
                                          Icons.download,
                                          size: 16,
                                        ),
                                        label: const Text('Download'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepOrange,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
    );
  }
}
