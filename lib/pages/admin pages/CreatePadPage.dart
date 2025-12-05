import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:file_picker/file_picker.dart';

class CreatePadPage extends StatefulWidget {
  const CreatePadPage({super.key});

  @override
  State<CreatePadPage> createState() => _CreatePadPageState();
}

class _CreatePadPageState extends State<CreatePadPage> {
  final _formKey = GlobalKey<FormState>();
  final _contactEmailController = TextEditingController(
    text: "pcist25@gmail.com",
  );
  final _contactPhoneController = TextEditingController(text: "+8801537624875");
  final _addressController = TextEditingController(
    text: "Institute of Science & Technology (IST), Dhaka",
  );
  final _receiverEmailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _statementController = TextEditingController();

  List<PadAuthorizer> authorizers = [];

  bool _sendViaEmail = false;
  String? _attachedFileName;
  PlatformFile? _attachedPdf;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    _receiverEmailController.dispose();
    _subjectController.dispose();
    _statementController.dispose();
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

  void _clearAttachment() {
    setState(() {
      _attachedPdf = null;
      _attachedFileName = null;
    });
  }

  Future<void> _attachPdfOnly() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() {
            _attachedPdf = file;
            _attachedFileName = file.name;
          });

          Get.snackbar(
            'Attached',
            'PDF file attached successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to attach PDF: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<File?> _prepareStatementPdf() async {
    if (_attachedPdf?.path != null) {
      return File(_attachedPdf!.path!);
    }
    return null;
  }

  Future<void> _generatePad() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isSubmitting = true);

      final validAuthorizers = authorizers
          .where((auth) => auth.name.isNotEmpty && auth.role.isNotEmpty)
          .toList();

      if (_sendViaEmail) {
        await Ontapprocesses.SendPadStatement(
          receiverEmail: _receiverEmailController.text,
          subject: _subjectController.text,
          statement: _statementController.text,
          authorizers: validAuthorizers,
          contactEmail: _contactEmailController.text,
          contactPhone: _contactPhoneController.text,
          address: _addressController.text,
        );
      } else {
        final pdfFile = await _prepareStatementPdf();
        if (pdfFile == null || !await pdfFile.exists()) {
          Get.snackbar(
            'Missing PDF',
            'Attach the generated PAD PDF before continuing.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }

        await Ontapprocesses.DownloadPadStatement(
          statementPdf: pdfFile,
          authorizers: validAuthorizers,
          contactEmail: _contactEmailController.text,
          contactPhone: _contactPhoneController.text,
          address: _addressController.text,
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
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
                    TextFormField(
                      controller: _statementController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Statement Text *',
                        hintText:
                            'Enter the official statement to include in the email',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (_sendViaEmail && (value == null || value.isEmpty)) {
                          return 'Please enter the statement text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Statement section
                  const Text(
                    'Official Statement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_sendViaEmail) ...[
                    const Text(
                      'Attach the generated PAD PDF created from the official template. Make sure the document already includes all required signatures and details.',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _attachPdfOnly,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Attach PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _attachedPdf == null
                              ? null
                              : _clearAttachment,
                          icon: const Icon(Icons.clear),
                          label: const Text('Remove'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_attachedFileName != null) ...[
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
                                'Attached PDF: $_attachedFileName',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _clearAttachment,
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Remove attachment'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],

                  // Authorizers section header
                  const Text(
                    'Authorizers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
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
                        border: Border.all(
                          color: const Color.fromARGB(255, 121, 118, 118),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
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
                                        final val = value ?? '';
                                        if (val.isNotEmpty &&
                                            authorizers[index].role.isEmpty) {
                                          return 'Please enter role when name is provided';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
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
                                        final val = value ?? '';
                                        if (val.isNotEmpty &&
                                            authorizers[index].name.isEmpty) {
                                          return 'Please enter name when role is provided';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(),
                                  IconButton(
                                    onPressed: () => _removeAuthorizer(index),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Add Authorizer button positioned before Contact Information
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _addAuthorizer,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Authorizer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
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
                      onPressed: _isSubmitting ? null : _generatePad,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(_sendViaEmail ? Icons.send : Icons.download),
                      label: Text(
                        _isSubmitting
                            ? 'Processing...'
                            : _sendViaEmail
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
