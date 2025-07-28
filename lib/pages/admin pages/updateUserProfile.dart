import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:pcist/secret.dart';

class UpdateUserProfile extends StatefulWidget {
  const UpdateUserProfile({super.key});

  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController(text: LoggedInUserData.name);
  final phoneController = TextEditingController(text: LoggedInUserData.phone);
  final emailController = TextEditingController(text: LoggedInUserData.email);
  final cfController = TextEditingController(text: LoggedInUserData.cfhandle);
  final atcController = TextEditingController(text: LoggedInUserData.atchandle);
  final ccController = TextEditingController(text: LoggedInUserData.cchandle);
  final tshirtController = TextEditingController(text: LoggedInUserData.tshirt);
  final deptController = TextEditingController(text: LoggedInUserData.dept);
  final batchController = TextEditingController(
    text: (LoggedInUserData.batch ?? 28).toString(),
  );

  String selectedGender = LoggedInUserData.gender ?? 'Male';

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  void saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final tokenData = await Tokenprocess.readToken();
      final token = tokenData['authToken'], slug = tokenData['slug'];

      Ontapprocesses.UpdateUserProfile(
        token: token,
        slug: slug,
        name: nameController.text,
        phone: phoneController.text,
        gender: selectedGender,
        tshirt: tshirtController.text,
        batch: batchController.text,
        dept: deptController.text,
        cfhandle: cfController.text,
        atchandle: atcController.text,
        cchandle: ccController.text,
      );

      Get.back();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User details updated")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          child: Container(
            width: Get.width * 0.85,
            height: Get.height * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color.fromARGB(255, 211, 119, 44),
                width: 4,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Edit Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField("Name", nameController),
                    buildTextField("Email", emailController),
                    buildTextField("Phone", phoneController),
                    buildDropdown(
                      "Gender",
                      genderOptions,
                      selectedGender,
                      (val) => setState(() => selectedGender = val ?? "Male"),
                    ),
                    buildNumberField("Batch", batchController),
                    buildTextField("Department", deptController),
                    buildTextField("T-Shirt Size", tshirtController),
                    buildTextField("Codeforces Handle", cfController),
                    buildTextField("AtCoder Handle", atcController),
                    buildTextField("CodeChef Handle", ccController),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: saveChanges,
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label cannot be empty";
          }
          if (int.tryParse(value) == null) {
            return "$label must be a number";
          }
          return null;
        },
      ),
    );
  }

  Widget buildDropdown(
    String label,
    List<String> options,
    String selectedValue,
    void Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: options
            .map(
              (value) =>
                  DropdownMenuItem<String>(value: value, child: Text(value)),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "$label cannot be empty" : null,
      ),
    );
  }
}
