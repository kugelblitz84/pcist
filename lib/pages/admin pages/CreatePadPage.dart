import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pcist/services/pdfTextExtractor.dart';

class CreatePadPage extends StatefulWidget {
  const CreatePadPage({super.key});

  @override
  State<CreatePadPage> createState() => _CreatePadPageState();
}

class _CreatePadPageState extends State<CreatePadPage> {
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();
  final _contactEmailController = TextEditingController(
    text: "contact@pcist.org",
  );
  final _contactPhoneController = TextEditingController(text: "+8801XXXXXXXXX");
  final _addressController = TextEditingController(
    text: "Institute of Science & Technology (IST), Dhaka",
  );
  final _receiverEmailController = TextEditingController();
  final _subjectController = TextEditingController();

  List<PadAuthorizer> authorizers = [];

  bool _sendViaEmail = false;
  bool _isExtractingText = false;
  String? _selectedFileName;

  @override
  void dispose() {
    _statementController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    _receiverEmailController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _addAuthorizer() {
    setState(() {
      authorizers.add(PadAuthorizer(name: "", role: ""));
    });
  }

  void _removeAuthorizer(int index) {
    setState(() {
      authorizers.removeAt(index);
    });
  }

  Future<void> _pickAndExtractPdfText() async {
    try {
      setState(() {
        _isExtractingText = true;
      });

      // Pick PDF file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.path != null) {
          setState(() {
            _selectedFileName = file.name;
          });

          // Extract text from PDF
          String extractedText = await PdfTextExtractor.extractTextFromPdf(
            file.path!,
          );

          if (extractedText.isNotEmpty) {
            setState(() {
              _statementController.text = extractedText;
            });

            Get.snackbar(
              'Success',
              'PDF text extracted successfully!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
          } else {
            Get.snackbar(
              'Warning',
              'No text could be extracted from the PDF file.',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to extract text from PDF: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isExtractingText = false;
      });
    }
  }

  void _clearStatement() {
    setState(() {
      _statementController.clear();
      _selectedFileName = null;
    });
  }

  void _generatePad() {
    if (_formKey.currentState!.validate()) {
      // Filter out empty authorizers
      final validAuthorizers = authorizers
          .where((auth) => auth.name.isNotEmpty && auth.role.isNotEmpty)
          .toList();

      if (_sendViaEmail) {
        Ontapprocesses.SendPadStatement(
          receiverEmail: _receiverEmailController.text,
          subject: _subjectController.text,
          statement: _statementController.text,
          authorizers: validAuthorizers,
          contactEmail: _contactEmailController.text,
          contactPhone: _contactPhoneController.text,
          address: _addressController.text,
        );
      } else {
        Ontapprocesses.DownloadPadStatement(
          statement: _statementController.text,
          authorizers: validAuthorizers,
          contactEmail: _contactEmailController.text,
          contactPhone: _contactPhoneController.text,
          address: _addressController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create PAD Statement'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Official Statement Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Send via email toggle
                  SwitchListTile(
                    title: const Text('Send via Email'),
                    subtitle: const Text(
                      'Toggle to send PAD via email or download as PDF',
                    ),
                    value: _sendViaEmail,
                    onChanged: (value) {
                      setState(() {
                        _sendViaEmail = value;
                      });
                    },
                    activeColor: Colors.deepOrange,
                  ),
                  const SizedBox(height: 16),

                  // Email fields (only shown if sending via email)
                  if (_sendViaEmail) ...[
                    TextFormField(
                      controller: _receiverEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Receiver Email *',
                        hintText: 'recipient@example.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (_sendViaEmail && (value == null || value.isEmpty)) {
                          return 'Please enter receiver email';
                        }
                        if (_sendViaEmail && !GetUtils.isEmail(value!)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Email Subject *',
                        hintText: 'pcIST — Official Statement',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subject),
                      ),
                      validator: (value) {
                        if (_sendViaEmail && (value == null || value.isEmpty)) {
                          return 'Please enter email subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Statement section with PDF import option
                  const Text(
                    'Official Statement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PDF Import buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isExtractingText
                              ? null
                              : _pickAndExtractPdfText,
                          icon: _isExtractingText
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: Text(
                            _isExtractingText
                                ? 'Extracting...'
                                : 'Import from PDF',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _statementController.text.isEmpty
                            ? null
                            : _clearStatement,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  if (_selectedFileName != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Imported from: $_selectedFileName',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Statement
                  TextFormField(
                    controller: _statementController,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Official Statement *',
                      hintText:
                          'Enter the official statement content here or import from PDF...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the statement or import from PDF';
                      }
                      if (value.length < 50) {
                        return 'Statement should be at least 50 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Authorizers section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Authorizers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addAuthorizer,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Authorizer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Authorizers list
                  if (authorizers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Center(
                        child: Text(
                          'Click "Add Authorizer" to add authorizers to this statement.',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ...authorizers.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: authorizers[index].name,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  onChanged: (value) {
                                    authorizers[index].name = value;
                                  },
                                  validator: (value) {
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        authorizers[index].role.isEmpty) {
                                      return 'Please enter role when name is provided';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: authorizers[index].role,
                                  decoration: const InputDecoration(
                                    labelText: 'Role/Designation',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.work),
                                  ),
                                  onChanged: (value) {
                                    authorizers[index].role = value;
                                  },
                                  validator: (value) {
                                    if (value != null &&
                                        value.isNotEmpty &&
                                        authorizers[index].name.isEmpty) {
                                      return 'Please enter name when role is provided';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _removeAuthorizer(index),
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Contact information section
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _contactEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Email *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Phone *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter contact phone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Address *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _generatePad,
                      icon: Icon(_sendViaEmail ? Icons.send : Icons.download),
                      label: Text(
                        _sendViaEmail
                            ? 'Send PAD Statement'
                            : 'Download PAD Statement',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
