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
    // Calibrate preview count to typical phone heights; keep conservative on short screens
    if (height < 480) return 1;
    if (height < 640) return 2;
    if (height < 720) return 3;
    if (height < 880) return 4;
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
    final double w = Get.width;
    final double h = Get.height;
    final double titleSize = math.max(18, math.min(24, w * 0.055));
    final double cardTitleSize = math.max(16, math.min(18, w * 0.045));
    final double bodySize = math.max(12, math.min(14, w * 0.04));
    final double smallGap = isLandscape
        ? math.max(4, h * 0.006)
        : math.max(6, h * 0.007);
    final double mediumGap = isLandscape
        ? math.max(6, h * 0.008)
        : math.max(8, h * 0.012);
    final double buttonHeight = math.max(32, math.min(36, h * 0.035));
    final EdgeInsetsGeometry cardPadding = EdgeInsets.symmetric(
      horizontal: 12,
      vertical: isLandscape ? math.max(4, h * 0.008) : math.max(6, h * 0.010),
    );

    final int maxByHeight = _computePreviewCount(Get.height);
    final int baseLimit = maxByHeight < _previewCount
        ? maxByHeight
        : _previewCount;
    final int limit = isLandscape && baseLimit > 3 ? 3 : baseLimit;
    final List<dynamic> preview = _contests.take(limit).toList(growable: false);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isLandscape ? math.min(16.0, Get.height * 0.02) : 16,
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
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: mediumGap),
                ...preview.map((contest) {
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: cardPadding,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contest['event'] ?? 'Unknown Contest',
                                  maxLines: isLandscape ? 1 : 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: cardTitleSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: smallGap),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 2,
                                  children: [
                                    Text(
                                      'Host: ${contest['host'] ?? 'Unknown'}',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: bodySize,
                                      ),
                                    ),
                                    if (contest['n_problems'] != null)
                                      Text(
                                        'Problems: ${contest['n_problems']}',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: bodySize,
                                        ),
                                      ),
                                  ],
                                ),
                                if (!isLandscape) ...[
                                  SizedBox(height: smallGap),
                                  if (contest['start'] != null)
                                    Text(
                                      'Start: ${formatDateTime(contest['start'])}',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: bodySize,
                                      ),
                                    ),
                                  if (contest['end'] != null)
                                    Text(
                                      'End: ${formatDateTime(contest['end'])}',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: bodySize,
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isLandscape) ...[
                                SizedBox.shrink(),
                              ] else ...[
                                if (contest['start'] != null)
                                  Text(
                                    'Start: ${formatDateTime(contest['start'])}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: bodySize,
                                    ),
                                  ),
                                if (contest['end'] != null)
                                  Text(
                                    'End: ${formatDateTime(contest['end'])}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: bodySize,
                                    ),
                                  ),
                                SizedBox(height: smallGap),
                              ],
                              SizedBox(
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (contest['href'] != null) {
                                      openContestLink(contest['href']);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: math.max(10, w * 0.02),
                                      vertical: math.max(6, h * 0.005),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Visit'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: mediumGap),
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

    final double w = Get.width;
    final double h = Get.height;
    final double toolbarH = math.max(42, math.min(52, h * 0.06));
    final double appBarTitleSize = math.max(19, math.min(22, w * 0.055));
    final double appBarIconSize = math.max(22, math.min(26, w * 0.06));
    final double cardTitleSize = math.max(16, math.min(18, w * 0.045));
    final double bodySize = math.max(12, math.min(14, w * 0.035));
    final double buttonHeight = math.max(32, math.min(36, h * 0.045));
    final double smallGap = isLandscape
        ? math.max(4, h * 0.006)
        : math.max(6, h * 0.008);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: toolbarH,
        title: Text(
          'All Contests',
          maxLines: isLandscape ? 1 : 2,
          style: TextStyle(
            fontSize: appBarTitleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(size: appBarIconSize),
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
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: isLandscape ? 8 : 10,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            contest['event'] ??
                                                'Unknown Contest',
                                            maxLines: isLandscape ? 1 : 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: cardTitleSize,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 2,
                                            children: [
                                              Text(
                                                'Host: ${contest['host'] ?? 'Unknown'}',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: bodySize,
                                                ),
                                              ),
                                              if (contest['n_problems'] != null)
                                                Text(
                                                  'Problems: ${contest['n_problems']}',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: bodySize,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (!isLandscape) ...[
                                            SizedBox(height: smallGap),
                                            if (contest['start'] != null)
                                              Text(
                                                'Start: ${formatDateTime(contest['start'])}',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: bodySize,
                                                ),
                                              ),
                                            if (contest['end'] != null)
                                              Text(
                                                'End: ${formatDateTime(contest['end'])}',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: bodySize,
                                                ),
                                              ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (isLandscape) ...[
                                          if (contest['start'] != null)
                                            Text(
                                              'Start: ${formatDateTime(contest['start'])}',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: bodySize,
                                              ),
                                            ),
                                          if (contest['end'] != null)
                                            Text(
                                              'End: ${formatDateTime(contest['end'])}',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: bodySize,
                                              ),
                                            ),
                                          SizedBox(height: smallGap),
                                        ],
                                        SizedBox(
                                          height: buttonHeight,
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
                                              padding: EdgeInsets.symmetric(
                                                horizontal: math.max(
                                                  10,
                                                  w * 0.02,
                                                ),
                                                vertical: math.max(
                                                  6,
                                                  h * 0.005,
                                                ),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Visit'),
                                          ),
                                        ),
                                      ],
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
