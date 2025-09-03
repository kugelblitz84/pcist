import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key});

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  final _formKey = GlobalKey<FormState>();
  final _authorizerNameController = TextEditingController();
  final _authorizerDesignationController = TextEditingController();
  final _contactEmailController = TextEditingController(text: "info@pcist.org");
  final _contactPhoneController = TextEditingController(
    text: "+880-123-456-7890",
  );
  final _addressController = TextEditingController(
    text: "Institute of Science & Technology (IST), Dhaka",
  );
  final _receiverEmailController = TextEditingController();
  final _subjectController = TextEditingController();

  List<InvoiceProduct> products = [
    InvoiceProduct(description: "", quantity: 1, unitPrice: 0.0),
  ];

  bool _sendViaEmail = false;

  @override
  void dispose() {
    _authorizerNameController.dispose();
    _authorizerDesignationController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    _receiverEmailController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _addProduct() {
    setState(() {
      products.add(
        InvoiceProduct(description: "", quantity: 1, unitPrice: 0.0),
      );
    });
  }

  void _removeProduct(int index) {
    if (products.length > 1) {
      setState(() {
        products.removeAt(index);
      });
    }
  }

  double _calculateGrandTotal() {
    return products.fold(0.0, (sum, product) => sum + product.totalPrice);
  }

  void _generateInvoice() {
    if (_formKey.currentState!.validate()) {
      if (_sendViaEmail) {
        Ontapprocesses.SendInvoice(
          receiverEmail: _receiverEmailController.text,
          subject: _subjectController.text,
          products: products,
          authorizerName: _authorizerNameController.text,
          authorizerDesignation: _authorizerDesignationController.text,
          contactEmail: _contactEmailController.text,
          contactPhone: _contactPhoneController.text,
          address: _addressController.text,
        );
      } else {
        Ontapprocesses.DownloadInvoice(
          products: products,
          authorizerName: _authorizerNameController.text,
          authorizerDesignation: _authorizerDesignationController.text,
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
        title: const Text('Create Invoice'),
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
                    'Invoice Details',
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
                      'Toggle to send invoice via email or download as PDF',
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
                        labelText: 'Client Email *',
                        hintText: 'client@example.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (_sendViaEmail && (value == null || value.isEmpty)) {
                          return 'Please enter client email';
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
                        hintText: 'Invoice from pcIST - Services',
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

                  // Authorizer Information
                  const Text(
                    'Authorizer Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Column(
                    children: [
                      TextFormField(
                        controller: _authorizerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Authorizer Name *',
                          hintText: 'Dr. John Doe',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person, size: 18),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter authorizer name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _authorizerDesignationController,
                        decoration: const InputDecoration(
                          labelText: 'Designation *',
                          hintText: 'Head of Department',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work, size: 18),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter designation';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Products section header
                  const Text(
                    'Products/Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Products list
                  ...products.asMap().entries.map((entry) {
                    int index = entry.key;
                    InvoiceProduct product = entry.value;
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
                              Text(
                                'Product ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              const Spacer(),
                              if (products.length > 1)
                                IconButton(
                                  onPressed: () => _removeProduct(index),
                                  icon: const Icon(Icons.remove_circle),
                                  color: Colors.red,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: product.description,
                            maxLines: 3,
                            minLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Description *',
                              hintText: 'Website Development',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.description),
                              alignLabelWithHint: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                products[index].description = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter product description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quantity',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      initialValue: product.quantity == 1
                                          ? ''
                                          : product.quantity.toString(),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter quantity',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 12,
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 14),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          products[index].quantity =
                                              int.tryParse(value) ?? 1;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter quantity';
                                        }
                                        if (int.tryParse(value) == null ||
                                            int.parse(value) <= 0) {
                                          return 'Valid quantity required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Unit Price (BDT)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextFormField(
                                      initialValue: product.unitPrice == 0.0
                                          ? ''
                                          : product.unitPrice.toString(),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter price',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 12,
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 14),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        setState(() {
                                          products[index].unitPrice =
                                              double.tryParse(value) ?? 0.0;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Enter price';
                                        }
                                        if (double.tryParse(value) == null ||
                                            double.parse(value) <= 0) {
                                          return 'Valid price required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Total: ৳${product.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // Add Product button positioned above Grand Total
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _addProduct,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Product'),
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
                  const SizedBox(height: 16),

                  // Grand Total
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepOrange),
                    ),
                    child: Text(
                      'Grand Total: ৳${_calculateGrandTotal().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                      textAlign: TextAlign.center,
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
                      onPressed: _generateInvoice,
                      icon: Icon(_sendViaEmail ? Icons.send : Icons.download),
                      label: Text(
                        _sendViaEmail ? 'Send Invoice' : 'Download Invoice',
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
