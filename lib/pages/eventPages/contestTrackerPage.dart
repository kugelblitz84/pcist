import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcist/services/eventApi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
// import your TrackedContests class here
// import 'package:pcist/api/event_api.dart';

class ContestTrackerPage extends StatefulWidget {
  const ContestTrackerPage({super.key});

  @override
  State<ContestTrackerPage> createState() => _ContestTrackerPageState();
}

class _ContestTrackerPageState extends State<ContestTrackerPage> {
  static const int _previewCount = 5;
  bool _loading = true;
  String? _error;
  List<dynamic> _contests = const [];

  @override
  void initState() {
    super.initState();
    _loadContests();
  }

  Future<void> _loadContests() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await TrackedContests.getContestTrackerData();
      final List<dynamic> objs = (data?['objects'] as List?) ?? [];
      setState(() {
        _contests = objs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading contests';
        _loading = false;
      });
    }
  }

  int _computePreviewCount(double height) {
    // Conservative thresholds for a non-scrollable area to avoid overflow
    if (height < 420) return 1; // very short screens or small landscape
    if (height < 520) return 2;
    if (height < 660) return 3;
    if (height < 800) return 4;
    return 5; // tall screens
  }

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

  // No search in the preview widget; only display a fixed number.

  @override
  Widget build(BuildContext context) {
    final int maxByHeight = _computePreviewCount(Get.height);
    final int limit = maxByHeight < _previewCount ? maxByHeight : _previewCount;
    final List<dynamic> preview = _contests.take(limit).toList(growable: false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : _contests.isEmpty
                  ? const Center(
                      child: Text(
                        'No upcoming contests',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Column(
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
                        const SizedBox(height: 12),
                        ...preview.map((contest) {
                          return Card(
                            color: Colors.white.withOpacity(0.1),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
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
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                  if (contest['n_problems'] != null)
                                    Text(
                                      'Problems: ${contest['n_problems']}',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  const SizedBox(height: 4),
                                  if (contest['start'] != null)
                                    Text(
                                      'Start: ${formatDateTime(contest['start'])}',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  if (contest['end'] != null)
                                    Text(
                                      'End: ${formatDateTime(contest['end'])}',
                                      style: const TextStyle(
                                          color: Colors.white70),
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
                        }).toList(),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FullContestListPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'View All Contests',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class FullContestListPage extends StatefulWidget {
  const FullContestListPage({super.key});

  @override
  State<FullContestListPage> createState() => _FullContestListPageState();
}

class _FullContestListPageState extends State<FullContestListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _loading = true;
  String? _error;
  List<dynamic> _contests = const [];

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
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await TrackedContests.getContestTrackerData();
      final List<dynamic> objs = (data?['objects'] as List?) ?? [];
      setState(() {
        _contests = objs;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading contests';
        _loading = false;
      });
    }
  }

  List<dynamic> _applySearch(List<dynamic> contests) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return contests;

    int score(Map c) {
      int s = 0;
      final event = (c['event'] ?? '').toString().toLowerCase();
      final host = (c['host'] ?? '').toString().toLowerCase();
      if (event.contains(q)) s += 2;
      if (host.contains(q)) s += 1;
      return s;
    }

    final filtered = contests
        .where((c) => score(c as Map) > 0)
        .toList(growable: false);
    filtered.sort((a, b) => score(b as Map).compareTo(score(a as Map)));
    return filtered;
  }

  void _performSearch([String? value]) {
    setState(() {
      _query = (value ?? _searchController.text).trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Contests'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _performSearch,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search contests by name or host...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.orangeAccent,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.orangeAccent,
                  ),
                  onPressed: _performSearch,
                  tooltip: 'Search',
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orangeAccent,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : _contests.isEmpty
                          ? const Center(
                              child: Text(
                                'No upcoming contests',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : Builder(builder: (context) {
                              final filtered = _applySearch(_contests);
                              return ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final contest = filtered[index];
                                  return Card(
                                    color: Colors.white.withOpacity(0.1),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 9,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contest['event'] ??
                                                'Unknown Contest',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Host: ${contest['host'] ?? 'Unknown'}',
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                          if (contest['n_problems'] != null)
                                            Text(
                                              'Problems: ${contest['n_problems']}',
                                              style: const TextStyle(
                                                  color: Colors.white70),
                                            ),
                                          const SizedBox(height: 4),
                                          if (contest['start'] != null)
                                            Text(
                                              'Start: ${formatDateTime(contest['start'])}',
                                              style: const TextStyle(
                                                  color: Colors.white70),
                                            ),
                                          if (contest['end'] != null)
                                            Text(
                                              'End: ${formatDateTime(contest['end'])}',
                                              style: const TextStyle(
                                                  color: Colors.white70),
                                            ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (contest['href'] != null) {
                                                  openContestLink(
                                                      contest['href']);
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.orangeAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child:
                                                  const Text('Visit Contest'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
            ),
          ],
        ),
      ),
    );
  }
}
