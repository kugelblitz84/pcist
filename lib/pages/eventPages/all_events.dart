import 'package:flutter/material.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pcist/services/eventApi.dart';
import 'package:pcist/pages/eventPages/EventRegister.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:pcist/secret.dart';
import 'viewEventParticipation.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  //bool _loading = true;
  bool isDeadlineOver(DateTime deadlineDate) {
    try {
      //final parsedDeadline = DateFormat('MM/dd/yyyy').parse(deadlineDate);
      final now = DateTime.now();
      return now.isAfter(deadlineDate.add(const Duration(days: 0)));
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _loadEvents() async {
  //   if (!Eventsconfig.eventsLoaded.value) {
  //     await Eventsconfig.initializeEvents();
  //   }
  //   setState(() {
  //     _loading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final events = Eventsconfig.allEvents;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Events'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () => Eventsconfig.eventsLoaded.value == false
            ? const Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              )
            : events.isEmpty
            ? const Center(
                child: Text(
                  'No events available at the moment.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Image
                        if (event.imageUrls.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              event.imageUrls.first,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${event.eventName} (${event.eventType})",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                        ),
                                        builder: (context) =>
                                            FractionallySizedBox(
                                              heightFactor:
                                                  LoggedInUserData.role == 2
                                                  ? 0.7
                                                  : 0.2,
                                              child: EventOptionsPopup(
                                                event: event,
                                              ),
                                            ),
                                      );
                                    },
                                    icon: Icon(Icons.menu),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    event.date != null
                                        ? DateFormat(
                                            'dd MMM yyyy, h:mm a',
                                          ).format(event.date!)
                                        : 'Date not set',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                              // 🔶 Registration Deadline Row
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    size: 20,
                                    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    event.registrationDeadline != null
                                        ? "Register by: ${DateFormat('dd MMM yyyy').format(event.registrationDeadline!)}"
                                        : "No deadline",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 20,
                                    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      event.location ?? 'No location',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  if (event.registrationDeadline != null &&
                                      !isDeadlineOver(
                                        event.registrationDeadline!,
                                      )) // 👈 fixed
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Get.to(EventRegister(event: event));
                                      },
                                      child: const Text(
                                        "Register",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  else
                                    Container(
                                      height: 50,
                                      width: 120,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Registration Closed",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepOrange,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                (event.description != null &&
                                        event.description!.length > 15)
                                    ? "${event.description!.substring(0, 15)}....."
                                    : event.description ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class EventOptionsPopup extends StatefulWidget {
  final Event event; // Ideally replace with your custom Event model

  const EventOptionsPopup({super.key, required this.event});

  @override
  State<EventOptionsPopup> createState() => _EventOptionsPopupState();
}

class _EventOptionsPopupState extends State<EventOptionsPopup> {
  late TextEditingController _descriptionController;
  late String _location;
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.event.description ?? '',
    );
    _location = widget.event.location ?? "No Location Provided";
    _selectedDeadline = widget.event.registrationDeadline;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  void _handleUpdate() {
    // Collect fields and call EventApi.updateEvent
    final String? id = widget.event.id;
    final String? description = _descriptionController.text;
    final String? location = _location;
    final String? registrationDeadline = _selectedDeadline != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDeadline!)
        : null;

    if (id == null || id.isEmpty) {
      Get.snackbar('Error', 'Invalid event id');
      return;
    }

    EventApi.updateEvent(
          id: id,
          description: description,
          location: location,
          registrationDeadline: registrationDeadline,
        )
        .then((response) {
          if (response != null && response.statusCode == 200) {
            Get.snackbar('Success', 'Event updated successfully');
            // Optionally refresh events list
            Eventsconfig.initializeEvents();
          } else {
            Get.snackbar('Error', 'Failed to update event');
            print(
              'Update event failed: ${response?.statusCode} ${response?.body}',
            );
          }
        })
        .catchError((err) {
          Get.snackbar('Error', 'Failed to update event: $err');
        })
        .whenComplete(() => Navigator.pop(context));
  }

  void _handleDelete() {
    //Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Ontapprocesses.deleteEvent(id: widget.event.id ?? "");
              //Get.back();
              // TODO: Handle delete event logic
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int role = LoggedInUserData.role ?? 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: (role == 2)
                  ? Text(
                      "Edit Event Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(widget.event.eventName ?? ""),
            ),
            const SizedBox(height: 24),

            // Show Registered Teams/Members (for all roles)
            ElevatedButton.icon(
              onPressed: () {
                Get.to(ViewParticipationPage(event: widget.event));
              },
              icon: Icon(
                widget.event.eventType == 'solo' ? Icons.people : Icons.groups,
              ),
              label: Text(
                widget.event.eventType == 'solo'
                    ? "Show Registered Members"
                    : "Show Registered Teams",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            if (role == 2) ...[
              // Only show the edit controls for role 2
              Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  const Text("Deadline:", style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _pickDeadline,
                    icon: const Icon(
                      Icons.edit_calendar,
                      color: Colors.deepOrange,
                    ),
                    label: Text(
                      _selectedDeadline != null
                          ? DateFormat('dd MMM yyyy').format(_selectedDeadline!)
                          : 'Select Date',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Description",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Enter event description...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Location",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _location,
                items: ["Auditorium", "Lab 1", "Lab 2"]
                    .map(
                      (location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _location = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Select Location'),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleUpdate,
                      icon: const Icon(Icons.save),
                      label: const Text("Update"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _handleDelete,
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
