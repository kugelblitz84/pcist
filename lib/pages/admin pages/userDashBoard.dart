import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/userApi.dart';
import 'updateUserProfile.dart';
import 'package:get/get.dart';

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
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Ontapprocesses.UploadToGallery();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      Get.width * 0.02, // 2% of screen width
                                  vertical:
                                      Get.height *
                                      0.015, // 1.5% of screen height
                                ),
                              ),
                              child: Text(
                                "Upload to gallery",
                                style: TextStyle(
                                  fontSize:
                                      Get.width * 0.04, // 4% of screen width
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: Get.width * 0.02,
                          ), // spacing between buttons
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed("/setEvent");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.02,
                                  vertical: Get.height * 0.015,
                                ),
                              ),
                              child: Text(
                                "Start New Event",
                                style: TextStyle(
                                  fontSize: Get.width * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Get.height * 0.015),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed('/userListPage');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.02,
                                  vertical: Get.height * 0.015,
                                ),
                              ),
                              child: Text(
                                "Manage Members",
                                style: TextStyle(
                                  fontSize: Get.width * 0.038,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: Get.width * 0.02),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.toNamed("/allEvents");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.02,
                                  vertical: Get.height * 0.015,
                                ),
                              ),
                              child: Text(
                                "Manage Events",
                                style: TextStyle(
                                  fontSize: Get.width * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
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
