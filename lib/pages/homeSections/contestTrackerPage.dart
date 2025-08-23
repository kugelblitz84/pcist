import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcist/services/eventApi.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

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
    if (height < 420) return 1;
    if (height < 520) return 2;
    if (height < 660) return 3;
    if (height < 800) return 4;
    return 5;
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

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final int maxByHeight = _computePreviewCount(Get.height);
    final int baseLimit = maxByHeight < _previewCount
        ? maxByHeight
        : _previewCount;
    // In landscape, cap further to avoid vertical overflow
    final int limit = isLandscape && baseLimit > 3 ? 3 : baseLimit;
    final List<dynamic> preview = _contests.take(limit).toList(growable: false);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isLandscape ? math.min(16.0, Get.height * 0.02) : 24,
      ),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
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
                Text(
                  'Upcoming Contests',
                  style: TextStyle(
                    fontSize: isLandscape ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isLandscape ? 8 : 12),
                ...preview.map((contest) {
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: isLandscape ? 6 : 9,
                      ),
                      child: isLandscape
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        contest['event'] ?? 'Unknown Contest',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 2,
                                        children: [
                                          Text(
                                            'Host: ${contest['host'] ?? 'Unknown'}',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          if (contest['n_problems'] != null)
                                            Text(
                                              'Problems: ${contest['n_problems']}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Right times + button
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (contest['start'] != null)
                                      Text(
                                        'Start: ${formatDateTime(contest['start'])}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    if (contest['end'] != null)
                                      Text(
                                        'End: ${formatDateTime(contest['end'])}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 35,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (contest['href'] != null) {
                                            openContestLink(contest['href']);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orangeAccent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Visit'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
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
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                if (contest['start'] != null)
                                  Text(
                                    'Start: ${formatDateTime(contest['start'])}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                if (contest['end'] != null)
                                  Text(
                                    'End: ${formatDateTime(contest['end'])}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
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
                SizedBox(height: isLandscape ? 8 : 12),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? 20 : 24,
                        vertical: isLandscape ? 8 : 12,
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
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
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
                  : Builder(
                      builder: (context) {
                        final filtered = _applySearch(_contests);
                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final contest = filtered[index];
                            return Card(
                              color: Colors.white.withOpacity(0.1),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: isLandscape ? 6 : 9,
                                ),
                                child: isLandscape
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  contest['event'] ??
                                                      'Unknown Contest',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Wrap(
                                                  spacing: 10,
                                                  runSpacing: 2,
                                                  children: [
                                                    Text(
                                                      'Host: ${contest['host'] ?? 'Unknown'}',
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                      ),
                                                    ),
                                                    if (contest['n_problems'] !=
                                                        null)
                                                      Text(
                                                        'Problems: ${contest['n_problems']}',
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              if (contest['start'] != null)
                                                Text(
                                                  'Start: ${formatDateTime(contest['start'])}',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              if (contest['end'] != null)
                                                Text(
                                                  'End: ${formatDateTime(contest['end'])}',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              const SizedBox(height: 6),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (contest['href'] != null) {
                                                    openContestLink(
                                                      contest['href'],
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orangeAccent,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text('Visit'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Column(
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
                                              color: Colors.white70,
                                            ),
                                          ),
                                          if (contest['n_problems'] != null)
                                            Text(
                                              'Problems: ${contest['n_problems']}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          if (contest['start'] != null)
                                            Text(
                                              'Start: ${formatDateTime(contest['start'])}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          if (contest['end'] != null)
                                            Text(
                                              'End: ${formatDateTime(contest['end'])}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (contest['href'] != null) {
                                                  openContestLink(
                                                    contest['href'],
                                                  );
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
                                              child: const Text(
                                                'Visit Contest',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
