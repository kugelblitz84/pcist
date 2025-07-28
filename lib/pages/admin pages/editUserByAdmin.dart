import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/userApi.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class EditUserByAdmin extends StatefulWidget {
  final String slug;
  const EditUserByAdmin({super.key, required this.slug});

  @override
  State<EditUserByAdmin> createState() => _EditUserByAdminState();
}

class _EditUserByAdminState extends State<EditUserByAdmin> {
  String name = '';
  String email = '';
  String cfHandle = '';
  String ccHandle = '';
  String atcHandle = '';
  String _id = '';
  bool membership = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getMemberData();
  }

  void getMemberData() async {
    try {
      final response = await UserAPI.getUserData(widget.slug);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          cfHandle = data['cfhandle'] ?? '';
          ccHandle = data['cchandle'] ?? '';
          atcHandle = data['atchandle'] ?? '';
          membership = data['membership'] ?? false;
          _id = data['_id'] ?? '';
          isLoading = false;
          print("it: $_id");
        });
      }
    } catch (err) {
      print("Error while loading data: $err");
    }
  }

  void toggleMembership(bool newValue) async {
    try {
      final uri = Uri.http(
        Secret.siteLink,
        '/api/v1/user/update-membership-status/$_id',
      );
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'];
      final slug = tokenData['slug'];
      final header = {
        "Content-type": "application/json",
        "authorization": "Bearer $token",
      };
      final body = jsonEncode({"slug": slug, "membership": newValue});
      final response = await http.post(uri, headers: header, body: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          membership = newValue;
        });
      } else {
        setState(() {
          membership = !newValue;
        });
        Get.snackbar("Error", "Something went wrong");
      }

      // Send updated status to backend (implement this in your API service)

      // final res = await UserAPI.updateMembership(widget.slug, membership);
      // if (res.statusCode != 200) {
      //   // Rollback on failure
      //   setState(() {
      //     membership = !newValue;
      //   });
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("Failed to update membership")),
      //   );
      // }
    } catch (e) {
      setState(() {
        membership = !newValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating membership")),
      );
    }
  }

  Widget buildUserDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isNotEmpty ? value : 'N/A')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Member"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildUserDetail("Name", name),
                      buildUserDetail("Email", email),
                      buildUserDetail("Codeforces", cfHandle),
                      buildUserDetail("CodeChef", ccHandle),
                      buildUserDetail("AtCoder", atcHandle),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Membership Status",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Switch(
                            value: membership,
                            onChanged: toggleMembership,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
