import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:pcist/preocesses/onTapProcesses.dart';

class SetEventPage extends StatefulWidget {
  const SetEventPage({super.key});

  @override
  State<SetEventPage> createState() => _SetEventPageState();
}

class _SetEventPageState extends State<SetEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _registrationDeadlineController =
      TextEditingController();

  String? _selectedLocation;
  bool _needMembership = false;
  List<File> _eventImages = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _eventImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
            ),
            labelStyle: const TextStyle(color: Colors.grey),
            floatingLabelStyle: const TextStyle(color: Colors.deepOrange),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Add New Event",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Event Name
                  TextFormField(
                    controller: _eventNameController,
                    decoration: const InputDecoration(labelText: 'Event Name'),
                  ),
                  const SizedBox(height: 10),

                  // Event Type
                  DropdownButtonFormField<String>(
                    value: _eventTypeController.text.isNotEmpty
                        ? _eventTypeController.text
                        : null,
                    items: ['solo', 'team']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _eventTypeController.text = value ?? '';
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Event Type'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select an event type'
                        : null,
                  ),
                  const SizedBox(height: 10),

                  // Event Date
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'mm/dd/yyyy',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.deepOrange,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        _dateController.text = DateFormat(
                          'MM/dd/yyyy',
                        ).format(pickedDate);
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Event Time
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'hh:mm AM/PM',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.deepOrange,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedTime != null) {
                        setState(() {
                          _timeController.text = pickedTime.format(context);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Registration Deadline
                  TextFormField(
                    controller: _registrationDeadlineController,
                    decoration: const InputDecoration(
                      labelText: 'Registration Deadline (mm/dd/yyyy)',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Colors.deepOrange,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              dialogBackgroundColor: Colors.white,
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (pickedDate != null) {
                        _registrationDeadlineController.text = DateFormat(
                          'MM/dd/yyyy',
                        ).format(pickedDate);
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // Location
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    items: ["Onsite", "Online", "Hybrid"]
                        .map(
                          (location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select Location',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 10),

                  // Membership Checkbox
                  Row(
                    children: [
                      Checkbox(
                        checkColor: Colors.white,
                        activeColor: Colors.deepOrange,
                        value: _needMembership,
                        onChanged: (value) {
                          setState(() {
                            _needMembership = value ?? false;
                          });
                        },
                      ),
                      const Text("Need Membership?"),
                    ],
                  ),

                  // Event Images Picker
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _eventImages.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cloud_upload_outlined),
                                SizedBox(height: 5),
                                Text("Click to upload event images"),
                              ],
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _eventImages.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      _eventImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final String _dateTime =
                            _dateController.text + ' ' + _timeController.text;
                        await Ontapprocesses.addEvent(
                          _eventNameController.text,
                          _eventTypeController.text,
                          _dateTime,
                          _selectedLocation ?? "null",
                          _descriptionController.text,
                          _eventImages,
                          _needMembership,
                          _registrationDeadlineController.text,
                        );
                      },
                      child: const Text(
                        "Create Event",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
