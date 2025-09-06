import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:intl/intl.dart';
import 'EventEditPage.dart';
import 'EventPaymentsPage.dart';

class ManageEventsPage extends StatefulWidget {
  const ManageEventsPage({super.key});

  @override
  State<ManageEventsPage> createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  @override
  void initState() {
    super.initState();
    if (!Eventsconfig.eventsLoaded.value) {
      Eventsconfig.initializeEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Events'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Obx(() {
        if (Eventsconfig.eventsLoaded.value == false) {
          return const Center(child: CircularProgressIndicator());
        }
        if (Eventsconfig.allEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.event_busy, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'No events found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Create a new event to get started.',
                  style: TextStyle(color: Colors.black45),
                ),
              ],
            ),
          );
        }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: Eventsconfig.allEvents.length,
            itemBuilder: (context, idx) {
              final e = Eventsconfig.allEvents[idx];
              return Card(
                elevation: 2,
                child: ListTile(
                  leading: Icon(
                    e.eventType == 'team' ? Icons.groups : Icons.person,
                    color: Colors.deepOrange,
                  ),
                  title: Text(e.eventName ?? 'Unnamed'),
                  subtitle: Text(
                    [
                      if (e.date != null)
                        DateFormat('dd MMM yyyy h:mm a').format(e.date!),
                      if (e.registrationDeadline != null)
                        'Deadline: ${DateFormat('dd MMM').format(e.registrationDeadline!)}',
                      e.location,
                    ].whereType<String>().join('  •  '),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') {
                        Get.to(() => EventEditPage(event: e));
                      } else if (val == 'payments') {
                        Get.to(() => const EventPaymentsPage());
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'payments',
                        child: ListTile(
                          leading: Icon(Icons.payments),
                          title: Text('Payments'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
      }),
    );
  }
}
