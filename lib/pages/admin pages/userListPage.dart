import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'dart:convert';
import 'package:pcist/secret.dart';
import 'package:get/get.dart';
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
                // Dropdown for selecting users per page
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.grey.shade300,
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('Name')),
                      Expanded(flex: 3, child: Text('Email')),
                      Expanded(flex: 2, child: Text('Membership')),
                    ],
                  ),
                ),

                // User List
                Expanded(
                  child: ListView.builder(
                    itemCount: currentUsers.length,
                    itemBuilder: (context, index) {
                      final user = currentUsers[index];
                      String nameDisplay = user['name'] ?? 'Unnamed';
                      if (user['role'] == 2) {
                        nameDisplay += " (admin)";
                      }

                      return InkWell(
                        onTap: () {
                          Get.to(EditUserByAdmin(slug: user['slug']));
                          // TODO: Navigate to detail page
                          // Navigator.push(context, MaterialPageRoute(builder: (_) => UserDetailsPage(userId: user['_id'])));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(nameDisplay)),
                              Expanded(
                                flex: 3,
                                child: Text(user['email'] ?? 'No Email'),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  user['membership'] == true
                                      ? 'Active'
                                      : 'Inactive',
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
