import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/secret.dart';
import 'package:pcist/services/userApi.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class EditUserByAdmin extends StatefulWidget {
  final String slug;
  final bool readOnly; // when true hide membership toggle
  const EditUserByAdmin({super.key, required this.slug, this.readOnly = false});

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
  String classroll = '';
  String batch = '';
  String tshirt = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getMemberData();
  }

  void getMemberData() async {
    try {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'] ?? '';
      final response = await UserAPI.getUserData(widget.slug, token: token);
      if (response != null && response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //print("data fetched: $data");
        setState(() {
          name = data['name'] ?? '';
          email = data['email'] ?? '';
          cfHandle = data['cfhandle'] ?? '';
          ccHandle = data['cchandle'] ?? '';
          atcHandle = data['atchandle'] ?? '';
          membership = data['membership'] ?? false;
          classroll = (data['classroll']?.toString() ?? '');
          batch = (data['batch']?.toString() ?? '');
          tshirt = data['tshirt']?.toString() ?? '';
          _id = data['_id'] ?? '';
          isLoading = false;
          //print("it: $_id");
        });
      }
    } catch (err) {
      print("Error while loading data: $err");
    }
  }

  void toggleMembership(bool newValue) async {
    if (newValue) {
      // Ask for duration in months if enabling membership
      int? selectedMonths = await showDialog<int>(
        context: context,
        builder: (context) {
          int? selected;
          return AlertDialog(
            title: const Text("Select Membership Duration"),
            content: StatefulBuilder(
              builder: (context, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  int month = index + 1;
                  return RadioListTile<int>(
                    title: Text("$month Month${month > 1 ? 's' : ''}"),
                    value: month,
                    groupValue: selected,
                    onChanged: (value) {
                      setState(() => selected = value);
                    },
                  );
                }),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected),
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );

      // Cancel if no selection
      if (selectedMonths == null) return;

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

        final body = jsonEncode({
          "slug": slug,
          "membership": true,
          "durationInMonths": selectedMonths, // Send this to backend
        });

        final response = await http.post(uri, headers: header, body: body);

        if (response.statusCode == 200) {
          setState(() => membership = true);
        } else {
          Get.snackbar("Error", "Something went wrong ${response.statusCode}");
        }
      } catch (e) {
        setState(() => membership = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating membership")),
        );
      }
    } else {
      // Directly disable without prompt
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

        final body = jsonEncode({"slug": slug, "membership": false});

        final response = await http.post(uri, headers: header, body: body);

        if (response.statusCode == 200) {
          setState(() => membership = false);
        } else {
          Get.snackbar("Error", "Something went wrong ${response.statusCode}");
        }
      } catch (e) {
        setState(() => membership = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating membership")),
        );
      }
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
      appBar: AppBar(
        title: Text(widget.readOnly ? "Member Details" : "Edit Member"),
        centerTitle: true,
      ),
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
                      buildUserDetail("Class Roll", classroll),
                      buildUserDetail("Batch", batch),
                      buildUserDetail("T-Shirt", tshirt),
                      buildUserDetail("Codeforces", cfHandle),
                      buildUserDetail("CodeChef", ccHandle),
                      buildUserDetail("AtCoder", atcHandle),
                      const SizedBox(height: 12),
                      if (!widget.readOnly)
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
