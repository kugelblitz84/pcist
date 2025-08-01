import 'package:flutter/material.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:pcist/pages/EventRegister.dart';

class AllEventsPage extends StatefulWidget {
  const AllEventsPage({super.key});

  @override
  State<AllEventsPage> createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  //bool _loading = true;

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
                              Text(
                                "${event.eventName} (${event.eventType})",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
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
                                  SizedBox(width: Get.width * 0.3),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      Get.to(EventRegister(event: event));
                                    },
                                    child: const Text(
                                      "Register",
                                      style: TextStyle(color: Colors.white),
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
