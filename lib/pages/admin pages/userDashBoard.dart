import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/secret.dart';
import 'updateUserProfile.dart';

class UserDashboard extends StatelessWidget {
  UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = LoggedInUserData.role == 2;
    final name = LoggedInUserData.name ?? "User";
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
    final fullName = isAdmin ? "$name (admin)" : name;

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
                              Get.to(() => UpdateUserProfile());
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
                    if (isAdmin) ...[
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed("/setEvent");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Start New Event",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed("/userListPage");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Manage Members",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
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
