import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'dart:convert';
import 'package:pcist/secret.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // for formatting date
import 'editUserByAdmin.dart';

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
    fetchUsers();
  }

  Future<void> fetchUsers() async {
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
        setState(() {
          users = jsonData['data'];
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
                        onPressed: fetchUsers,
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
                        flex: 2,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Email',
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
                      if (user['role'] == 2) {
                        nameDisplay += " (admin)";
                      }

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

                      return InkWell(
                        onTap: () =>
                            Get.to(EditUserByAdmin(slug: user['slug'])),
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
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: Text(nameDisplay),
                                ),
                              ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(user['email'] ?? 'No Email'),
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
}
