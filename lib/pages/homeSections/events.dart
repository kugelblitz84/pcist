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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'UPCOMING EVENTS',
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: isLandscape ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.deepOrange,
            thickness: isLandscape ? 1.5 : 2,
          ),
        ),

        //const SizedBox(height: 10),
        Obx(() {
          if (Eventsconfig.eventsLoaded.value == false) {
            return CircularProgressIndicator();
          }

          final rawEvents = Eventsconfig.allEvents;
          final displayList = rawEvents.take(3).toList(growable: false);

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
        SizedBox(height: isLandscape ? 8 : 12),
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
      ],
    );
  }
}
