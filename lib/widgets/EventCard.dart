import 'package:flutter/material.dart';
import 'package:pcist/pages/eventPages/EventRegister.dart';
import 'package:pcist/secret.dart';
import 'package:get/get.dart';
// import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event data;
  const EventCard({super.key, required this.data});

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
  Widget build(BuildContext context) {
    final bool deadlineOver =
        data.registrationDeadline != null &&
        isDeadlineOver(data.registrationDeadline!);

    return Container(
      margin: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(157, 5, 5, 5),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${data.eventName} (${data.eventType})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.date.toString(),
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.location ?? "Please contact an admin for location",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 248, 248, 248),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (data.registrationDeadline != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.hourglass_bottom,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Deadline: ${data.registrationDeadline!}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    deadlineOver
                        ? const Text(
                            "Registration Closed",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              Get.to(EventRegister(event: data));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
