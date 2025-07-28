// import 'package:flutter/material.dart';

// class Events extends StatelessWidget {
//   const Events({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           'UPCOMING EVENTS',
//           style: TextStyle(
//               color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Divider(
//             color: Colors.deepOrange,
//           ),
//         ),

//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pcist/config/eventsConfig.dart';
import 'package:pcist/pages/all_events.dart';
import 'package:pcist/widgets/EventCard.dart';
import 'package:pcist/widgets/fade_slide_in.dart';
import 'package:get/get.dart';

class Events extends StatefulWidget {
  Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final eventsList = Eventsconfig.allEvents.take(3).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text(
            'UPCOMING EVENTS',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(color: Colors.deepOrange, thickness: 2),
        ),

        //const SizedBox(height: 10),
        Obx(() {
          if (Eventsconfig.eventsLoaded.value == false) {
            return CircularProgressIndicator();
          } else if (eventsList.isEmpty) {
            return Center(
              child: Text(
                'No Upcoming Events',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'monospace',
                  decoration: TextDecoration.none,
                  color: Colors.white,
                ),
              ),
            );
          } else {
            return SizedBox(
              height: Get.height * 0.7,
              child: Column(
                children: eventsList
                    .map(
                      (event) => FadeSlideIn(
                        child: EventCard(
                          data: event,
                          // title: event.eventName.toString(),
                          // date: event.date.toString(),
                          // location: event.location.toString(),
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          }
        }),
        // EventCard(
        //   title: 'Clash of Codes 2025',
        //   date: '19 March 2025',
        //   time: '1.30 PM',
        //   location: 'IST LAB',
        // ),
        // //const SizedBox(height: 15),
        // EventCard(
        //   title: 'Battle Of Brains 2025',
        //   date: '25 April 2025',
        //   time: '10:30 PM',
        //   location: 'IST LAB 2',
        // ),
        // EventCard(
        //   title: 'Battle Of Brains 2025',
        //   date: '25 April 2025',
        //   time: '10:30 PM',
        //   location: 'IST LAB 2',
        // ),
        const SizedBox(height: 15),
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
