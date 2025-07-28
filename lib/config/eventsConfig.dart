import 'dart:async';
import 'package:get/get.dart';
import 'package:pcist/services/eventApi.dart';
import 'package:pcist/secret.dart';

class Eventsconfig extends GetxController {
  static RxBool eventsLoaded = false.obs;
  static List<Event> allEvents = [];

  static Future<void> initializeEvents() async {
    print("event config called");
    try {
      final res = await EventApi.getEvents();
      if (res != null) {
        final soloList = res['soloEvents'] != null
            ? List<Event>.from(
                res['soloEvents'].map((e) => Event.setDataFromJson(e)),
              )
            : [];
        final teamList = res['teamEvents'] != null
            ? List<Event>.from(
                res['teamEvents'].map((e) => Event.setDataFromJson(e)),
              )
            : [];
        allEvents = [...soloList, ...teamList];
        eventsLoaded.value = true;
      } else {
        print("Invalid event data format received");
      }
      // if (res != null &&
      //     res['soloEvents'] != null &&
      //     res['teamEvents'] != null) {
      //

      //   final teamList = List<Event>.from(
      //     res['teamEvents'].map((e) => Event.setDataFromJson(e)),
      //   );
    } catch (e) {
      print("error in the eventsConfig class: $e");
    }
  }
}
