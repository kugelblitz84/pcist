import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcist/services/eventApi.dart';
import 'package:url_launcher/url_launcher.dart';
// import your TrackedContests class here
// import 'package:pcist/api/event_api.dart';

class ContestTrackerPage extends StatelessWidget {
  const ContestTrackerPage({super.key});

  String formatDateTime(String datetime) {
    final dt = DateTime.parse(datetime);
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  Future<void> openContestLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
    )) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: FutureBuilder<dynamic>(
        future: TrackedContests.getContestTrackerData(), // use cached API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading contests',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData ||
              snapshot.data['objects'] == null ||
              (snapshot.data['objects'] as List).isEmpty) {
            return Center(
              child: Text(
                'No upcoming contests',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final List<dynamic> contests = snapshot.data['objects'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Contests',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: contests.length,
                  itemBuilder: (context, index) {
                    final contest = contests[index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contest['event'] ?? 'Unknown Contest',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Host: ${contest['host'] ?? 'Unknown'}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            if (contest['n_problems'] != null)
                              Text(
                                'Problems: ${contest['n_problems']}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            const SizedBox(height: 4),
                            if (contest['start'] != null)
                              Text(
                                'Start: ${formatDateTime(contest['start'])}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            if (contest['end'] != null)
                              Text(
                                'End: ${formatDateTime(contest['end'])}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (contest['href'] != null) {
                                    openContestLink(contest['href']);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Visit Contest'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Navigate to dedicated contests page
              //       // Navigator.push(context, MaterialPageRoute(builder: (_) => DedicatedContestPage()));
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.orangeAccent,
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 24,
              //         vertical: 12,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     child: const Text(
              //       'View All Contests',
              //       style: TextStyle(fontSize: 16),
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }
}
