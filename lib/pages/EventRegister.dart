import 'package:flutter/material.dart';
import 'package:pcist/secret.dart'; // Assumes Event model is here

class EventRegister extends StatelessWidget {
  final Event event;

  EventRegister({super.key, required this.event});

  final Color accent = Colors.deepOrange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accent,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Text("Register For Event"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Name
            Text(
              event.eventName ?? "Untitled Event",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Images
            if (event.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: event.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          event.imageUrls[index],
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Description
            Text(
              event.description ?? "No description provided.",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Date and Time
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.deepOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  event.date.toString(),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Time (optional)
            // Row(
            //   children: [
            //     const Icon(Icons.access_time, size: 20, color: Colors.black54),
            //     const SizedBox(width: 8),
            //     Text(event.time.toString(), style: const TextStyle(color: Colors.black)),
            //   ],
            // ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 20,
                  color: Colors.deepOrange,
                ),
                const SizedBox(width: 8),
                Text(
                  event.location ?? "No location",
                  style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Registration Fields
            if (event.eventType == "solo") ...[
              const Text(
                "Enter contest as",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: accent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                  hintText: 'Your Name or Handle',
                ),
              ),
            ] else ...[
              const Text(
                "Team Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: accent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accent, width: 2),
                  ),
                  hintText: 'Enter team name',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Team Members",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              for (int i = 1; i <= 3; i++) ...[
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: accent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: accent, width: 2),
                    ),
                    hintText: 'Email of Contestant $i',
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],

            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // TODO: Handle submission
                },
                child: const Text(
                  "Submit Registration",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
