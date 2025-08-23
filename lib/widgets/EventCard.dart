import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pcist/pages/eventPages/EventRegister.dart';
import 'package:pcist/secret.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // import intl

class EventCard extends StatelessWidget {
  final Event data;
  const EventCard({super.key, required this.data});

  bool isDeadlineOver(DateTime deadlineDate) {
    try {
      final now = DateTime.now();
      return now.isAfter(deadlineDate);
    } catch (e) {
      return false;
    }
  }

  String formatDateTime(DateTime dateTime) {
    // Format: "dd MMM yyyy, hh:mm a" -> e.g., "18 Aug 2025, 02:30 PM"
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final bool deadlineOver =
        data.registrationDeadline != null &&
        isDeadlineOver(data.registrationDeadline!);

    Widget infoChip(
      IconData icon,
      String text, {
      TextStyle? style,
      double? maxWidth,
    }) {
      final textWidget = Text(
        text,
        style: style,
        overflow: maxWidth != null
            ? TextOverflow.ellipsis
            : TextOverflow.visible,
        softWrap: maxWidth == null,
      );
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          if (maxWidth != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: textWidget,
            )
          else
            textWidget,
        ],
      );
    }

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth >= 600 ||
              MediaQuery.of(context).orientation == Orientation.landscape;
          final titleStyle = const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          );
          final infoStyle = TextStyle(
            fontSize: isWide ? 13 : 14,
            color: const Color.fromARGB(255, 248, 248, 248),
          );
          final runSpacing = isWide ? 6.0 : 4.0;
          final spacing = isWide ? 16.0 : 12.0;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and action on the same row to save vertical space
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "${data.eventName} (${data.eventType})",
                        style: titleStyle,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ],
                ),
                SizedBox(height: isWide ? 8 : 10),

                // In wide/landscape, place info in a Wrap to utilize width
                if (isWide)
                  Wrap(
                    spacing: spacing,
                    runSpacing: runSpacing,
                    children: [
                      infoChip(
                        Icons.calendar_today,
                        formatDateTime(data.date ?? DateTime.now()),
                        style: infoStyle,
                      ),
                      infoChip(
                        Icons.location_on,
                        data.location ?? "Please contact an admin for location",
                        style: infoStyle,
                        maxWidth: math.min(constraints.maxWidth * 0.5, 420),
                      ),
                      if (data.registrationDeadline != null)
                        infoChip(
                          Icons.hourglass_bottom,
                          "Deadline: ${formatDateTime(data.registrationDeadline!)}",
                          style: infoStyle,
                        ),
                    ],
                  )
                else ...[
                  // Portrait/smaller widths: keep vertical, but compact
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDateTime(data.date ?? DateTime.now()),
                        style: infoStyle,
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
                      Expanded(
                        child: Text(
                          data.location ??
                              "Please contact an admin for location",
                          style: infoStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  if (data.registrationDeadline != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.hourglass_bottom,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Deadline: ${formatDateTime(data.registrationDeadline!)}",
                          style: infoStyle,
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
