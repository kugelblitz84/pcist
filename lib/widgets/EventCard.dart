import 'package:flutter/material.dart';
import 'package:pcist/pages/EventRegister.dart';
import 'package:pcist/secret.dart';
import 'package:get/get.dart';

class EventCard extends StatelessWidget {
  // final String title;
  // final String date;
  // //final String time;
  // final String location;
  // //final String displayDate;
  final Event data;
  const EventCard({
    super.key,
    required this.data,
    //required this.displayDate,
  });

  @override
  Widget build(BuildContext context) {
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
                  "${data.eventName} (${data.eventType})" ?? "Untitled",
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
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.date.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.location ?? "Please contact an admin for loaction",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 248, 248, 248),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // OutlinedButton(
                    //   onPressed: () {
                    //     // Navigate to event details
                    //   },
                    //   style: OutlinedButton.styleFrom(
                    //     side: const BorderSide(color: Colors.deepOrange),
                    //     foregroundColor: Colors.deepOrange,
                    //   ),
                    //   child: const Text('View Details'),
                    // ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle registration
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
