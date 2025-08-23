import 'package:flutter/material.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:pcist/pages/eventPages/all_events.dart';
import 'package:pcist/widgets/EventCard.dart';
import 'package:pcist/widgets/fade_slide_in.dart';
import 'package:get/get.dart';

class Events extends StatefulWidget {
  Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final w = Get.width;
    final h = Get.height;
    final titleSize = isLandscape
        ? (w * 0.042).clamp(16, 20)
        : (w * 0.055).clamp(20, 24);
    final dividerThickness = isLandscape
        ? (h * 0.0016).clamp(1.0, 2.0)
        : (h * 0.0022).clamp(1.5, 2.5);
    final vGap = isLandscape
        ? (h * 0.012).clamp(6, 12)
        : (h * 0.016).clamp(10, 16);
    // Compute a safe preview count based on height to avoid overflow
    int computePreviewCount() {
      final base = isLandscape ? 2 : 3;
      if (h < 520) return 1;
      if (h < 650) return base - 1;
      return base;
    }

    final previewCount = computePreviewCount().clamp(1, 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'UPCOMING EVENTS',
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: titleSize.toDouble(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.deepOrange,
            thickness: dividerThickness.toDouble(),
          ),
        ),

        //const SizedBox(height: 10),
        Obx(() {
          if (Eventsconfig.eventsLoaded.value == false) {
            return CircularProgressIndicator();
          }

          final rawEvents = Eventsconfig.allEvents;
          final displayList = rawEvents
              .take(previewCount)
              .toList(growable: false);

          if (displayList.isEmpty) {
            return Center(
              child: Text(
                'No Upcoming Events',
                style: TextStyle(
                  fontSize: 18,
                  decoration: TextDecoration.none,
                  color: Colors.white,
                ),
              ),
            );
          } else {
            // Use a simple Column to avoid inner vertical scrolling that would conflict with the PageView.
            return Column(
              children: displayList
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: FadeSlideIn(child: EventCard(data: event)),
                    ),
                  )
                  .toList(),
            );
          }
        }),
        SizedBox(height: vGap.toDouble()),
        Center(
          child: ElevatedButton(
            onPressed: () {
              // Navigate to events page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllEventsPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text(
              'View All Events',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: vGap.toDouble()),
      ],
    );
  }
}
