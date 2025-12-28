import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/userApi.dart';
import 'updateUserProfile.dart';

class UserDashboard extends StatelessWidget {
  UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final name = LoggedInUserData.name ?? "User";
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
    final fullName = name; // Unified UI: remove admin suffix

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(144, 148, 201, 241),
              Color.fromARGB(143, 248, 146, 87),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: Get.height * 0.90,
              width: Get.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color.fromARGB(255, 211, 119, 44),
                  width: 4,
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withAlpha(10),
                //     blurRadius: 10,
                //     offset: const Offset(0, 5),
                //   ),
                // ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: IconButton(
                            onPressed: () {
                              if (LoggedInUserData.isEmailVerified) {
                                Get.to(() => UpdateUserProfile());
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ), // Orange
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: Colors.deepOrange, // Blue border
                                        width: 2,
                                      ),
                                    ),
                                    title: const Text(
                                      "Email Not Verified",
                                      style: TextStyle(
                                        color: Colors.deepOrange, // Dark text
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: const Text(
                                      "Please verify your email to update your profile.",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              Colors.deepOrange, // Blue
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.settings),
                          ),
                        ),
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.deepOrange,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Title Badge - subtle display for organizational role
                    if (LoggedInUserData.title != 'Member') ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTitleColor(
                            LoggedInUserData.title,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getTitleColor(
                              LoggedInUserData.title,
                            ).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          LoggedInUserData.titleFullName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getTitleColor(LoggedInUserData.title),
                          ),
                        ),
                      ),
                    ],
                    if (!LoggedInUserData.isEmailVerified) ...[
                      SizedBox(height: 15),
                      Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            SizedBox(width: Get.width * 0.145),
                            Text("User not verified "),
                            GestureDetector(
                              child: Text(
                                "Verify now?",
                                style: TextStyle(color: Colors.deepOrange),
                              ),
                              onTap: () async {
                                final tokenData =
                                    await Tokenprocess.readToken();
                                final token = tokenData['authToken'],
                                    slug = tokenData['slug'];
                                UserAPI.sendVerificationMail(
                                  token ?? "",
                                  slug ?? "",
                                );
                                Get.toNamed('/OtpPage');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Divider(height: 30, thickness: 1.2),
                    infoRow(
                      label: "Class Roll",
                      value: LoggedInUserData.classroll ?? "N/A",
                    ),
                    infoRow(
                      label: "Email",
                      value: LoggedInUserData.email ?? "N/A",
                    ),
                    infoRow(
                      label: "Phone",
                      value: LoggedInUserData.phone ?? "N/A",
                    ),
                    infoRow(
                      label: "Gender",
                      value: LoggedInUserData.gender ?? "N/A",
                    ),
                    infoRow(
                      label: "Batch",
                      value: LoggedInUserData.batch?.toString() ?? "N/A",
                    ),
                    infoRow(
                      label: "Department",
                      value: LoggedInUserData.dept ?? "N/A",
                    ),
                    infoRow(
                      label: "T-Shirt",
                      value: LoggedInUserData.tshirt ?? "N/A",
                    ),
                    infoRow(
                      label: "Membership",
                      value: LoggedInUserData.membership ? "Yes" : "No",
                    ),
                    infoRow(
                      label: "CF Handle",
                      value: LoggedInUserData.cfhandle ?? "N/A",
                    ),
                    infoRow(
                      label: "AtCoder Handle",
                      value: LoggedInUserData.atchandle ?? "N/A",
                    ),
                    infoRow(
                      label: "CodeChef Handle",
                      value: LoggedInUserData.cchandle ?? "N/A",
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Badges: ${LoggedInUserData.badges.join(', ')}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Certificates: ${LoggedInUserData.certificates.join(', ')}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(height: 30, thickness: 1.2),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _showParticipationsSheet(context),
                        icon: const Icon(Icons.visibility),
                        label: const Text('View My Participations'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Edit user details navigation
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blueGrey,
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 24,
                    //       vertical: 12,
                    //     ),
                    //   ),
                    //   child: const Text(
                    //     "Edit User Details",
                    //     style: TextStyle(fontSize: 16, color: Colors.white),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class infoRow extends StatelessWidget {
  final String label, value;
  const infoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

void _showParticipationsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _ParticipationsSheetContent(),
  );
}

class _ParticipationsSheetContent extends StatefulWidget {
  const _ParticipationsSheetContent();
  @override
  State<_ParticipationsSheetContent> createState() =>
      _ParticipationsSheetContentState();
}

class _ParticipationsSheetContentState
    extends State<_ParticipationsSheetContent> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() => _query = _search.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final solo = LoggedInUserData.myParticipationsSolo;
    final team = LoggedInUserData.myParticipationsTeam;
    return DefaultTabController(
      length: 2,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: const [
                  Text(
                    'My Participations',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search events...',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _search.clear(),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TabBar(
              labelColor: Colors.deepOrange,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.deepOrange,
              tabs: [
                Tab(text: 'Solo (${solo.length})'),
                Tab(text: 'Team (${team.length})'),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                children: [
                  _buildGroupedList<UserSoloParticipation>(
                    items: solo,
                    icon: Icons.person_outline,
                    scrollController: scrollController,
                  ),
                  _buildGroupedList<UserTeamParticipation>(
                    items: team,
                    icon: Icons.groups_2_outlined,
                    scrollController: scrollController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList<T>({
    required List<dynamic> items,
    required IconData icon,
    required ScrollController scrollController,
  }) {
    // Filter
    final filtered = items
        .where((e) => (e.eventName ?? '').toLowerCase().contains(_query))
        .toList();
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _query.isEmpty ? 'No events' : 'No results for "$_query"',
          style: const TextStyle(color: Colors.black54),
        ),
      );
    }
    // Group by first letter
    final Map<String, List<dynamic>> groups = {};
    for (final item in filtered) {
      final name = (item.eventName ?? 'Unnamed').trim();
      final letter = name.isNotEmpty ? name[0].toUpperCase() : '#';
      groups.putIfAbsent(letter, () => []).add(item);
    }
    final sortedKeys = groups.keys.toList()..sort();
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final list = groups[key]!
          ..sort((a, b) => (a.eventName ?? '').compareTo(b.eventName ?? ''));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            ...list.map(
              (p) => _ParticipationTile(
                icon: icon,
                name: p.eventName ?? 'Unnamed',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ParticipationTile extends StatelessWidget {
  final IconData icon;
  final String name;
  const _ParticipationTile({required this.icon, required this.name});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.deepOrange),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

/// Helper function to get title badge color
Color _getTitleColor(String title) {
  switch (title) {
    case 'GS':
      return const Color(0xFFD4AF37); // Gold
    case 'JS':
      return const Color(0xFFC0C0C0); // Silver
    case 'OS':
      return const Color(0xFFCD7F32); // Bronze
    default:
      return Colors.grey;
  }
}
