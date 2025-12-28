import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'dart:convert';
import 'package:pcist/secret.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // for formatting date
import 'EditUserPage.dart';

/// Simple in-memory cache for user list data
class _UserListCache {
  static List<dynamic>? _cachedUsers;
  static DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  static bool get isValid {
    if (_cachedUsers == null || _lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  static List<dynamic>? get users => _cachedUsers;

  static void set(List<dynamic> users) {
    _cachedUsers = users;
    _lastFetchTime = DateTime.now();
  }

  static void invalidate() {
    _cachedUsers = null;
    _lastFetchTime = null;
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> users = [];
  bool isLoading = true;
  int usersPerPage = 10;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// Load users from cache if valid, otherwise fetch from API
  Future<void> _loadUsers({bool forceRefresh = false}) async {
    if (!forceRefresh && _UserListCache.isValid) {
      // Use cached data
      setState(() {
        users = _UserListCache.users!;
        isLoading = false;
      });
      return;
    }
    await _fetchUsersFromApi();
  }

  Future<void> _fetchUsersFromApi() async {
    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'];
      final slug = tokenData['slug'];
      final uri = Uri.http(Secret.siteLink, '/api/v1/user/get-user-list');
      final headers = {
        "Content-type": "application/json",
        "authorization": "Bearer $token",
      };
      final body = jsonEncode({"slug": slug});
      final response = await http.post(uri, headers: headers, body: body);
      final jsonData = json.decode(response.body);

      if (jsonData['success'] == true) {
        final fetchedUsers = jsonData['data'] as List<dynamic>;
        _UserListCache.set(fetchedUsers);
        setState(() {
          users = fetchedUsers;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch users");
      }
    } catch (e) {
      print('Error fetching users: $e');
      setState(() => isLoading = false);
    }
  }

  /// Force refresh data from API
  Future<void> _refreshUsers() async {
    setState(() => isLoading = true);
    await _fetchUsersFromApi();
  }

  @override
  Widget build(BuildContext context) {
    int start = currentPage * usersPerPage;
    int end = (start + usersPerPage).clamp(0, users.length);
    List currentUsers = users.sublist(start, end);

    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text("Users per page: "),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                        value: usersPerPage,
                        items: [10, 15, 20]
                            .map(
                              (count) => DropdownMenuItem(
                                value: count,
                                child: Text('$count'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              usersPerPage = value;
                              currentPage = 0;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _refreshUsers,
                        icon: Icon(Icons.refresh),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: currentPage > 0
                            ? () => setState(() => currentPage--)
                            : null,
                      ),
                      Text('${currentPage + 1}'),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: (start + usersPerPage) < users.length
                            ? () => setState(() => currentPage++)
                            : null,
                      ),
                    ],
                  ),
                ),

                // Table header
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Title',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Membership',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 24), // Space for chevron icon
                    ],
                  ),
                ),

                // User list
                Expanded(
                  child: ListView.builder(
                    itemCount: currentUsers.length,
                    itemBuilder: (context, index) {
                      final user = currentUsers[index];
                      String nameDisplay = user['name'] ?? 'Unnamed';

                      bool isMember = user['membership'] == true;
                      String membershipExpiry = '';

                      if (user['membershipExpiresAt'] != null) {
                        try {
                          DateTime expiryDate = DateTime.parse(
                            user['membershipExpiresAt'],
                          );
                          membershipExpiry = DateFormat(
                            'dd MMM yyyy',
                          ).format(expiryDate);
                        } catch (e) {
                          membershipExpiry = 'Invalid date';
                        }
                      }

                      // Title and role info
                      final String title = user['title'] ?? 'Member';
                      final bool isAdmin = user['role'] == 2;
                      final bool isTreasurer = user['treasurer'] ?? false;

                      return InkWell(
                        onTap: () async {
                          await Get.to(() => EditUserPage(user: user));
                          // Refresh list after returning (invalidate cache since user may have changed)
                          _UserListCache.invalidate();
                          _loadUsers();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nameDisplay,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontStyle: isAdmin ? FontStyle.italic : FontStyle.normal,
                                          color: isAdmin ? Colors.indigo : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // Role indicators below name
                                      if (isAdmin || isTreasurer)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Wrap(
                                            spacing: 4,
                                            children: [
                                              if (isAdmin)
                                                Text(
                                                  'Admin',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.indigo.shade400,
                                                  ),
                                                ),
                                              if (isTreasurer)
                                                Text(
                                                  'Treasurer',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontStyle: FontStyle.italic,
                                                    color: Colors.green.shade600,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: title != 'Member'
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getTitleColor(title).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            _getTitleShortName(title),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getTitleColor(title),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Member',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isMember ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color: isMember
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isMember && membershipExpiry.isNotEmpty)
                                      Text(
                                        'Expires on $membershipExpiry',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Edit icon
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.deepOrange,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Color _getTitleColor(String title) {
    switch (title) {
      case 'GS':
        return const Color(0xFFD4AF37); // Gold
      case 'JS':
        return const Color(0xFF7B7B7B); // Silver/Gray
      case 'OS':
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  String _getTitleShortName(String title) {
    switch (title) {
      case 'GS':
        return 'General Secretary';
      case 'JS':
        return 'Joint Secretary';
      case 'OS':
        return 'Organizing Secretary';
      default:
        return 'Member';
    }
  }
}
