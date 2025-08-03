// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/authProcesses/tokenProcess.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:pcist/pages/homePage.dart';
//import 'package:pcist/services/userApi.dart';

class MemberFormPage extends StatelessWidget {
  MemberFormPage({super.key});

  final TextEditingController _nameCon = TextEditingController();
  final TextEditingController _phoneCon = TextEditingController();
  final TextEditingController _batchCon = TextEditingController();
  final TextEditingController _cfCon = TextEditingController();
  final TextEditingController _atcCon = TextEditingController();
  final TextEditingController _ccCon = TextEditingController();

  final RxString selectedGender = ''.obs;
  final RxString selectedShirtSize = ''.obs;
  final RxString selectedDept = ''.obs;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> shirtSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<String> departments = ['CSE', 'EEE', 'BBA', 'ENG', 'Other'];

  InputDecoration _textFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepOrange, width: 2.5),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2.5),
      ),
      floatingLabelStyle: const TextStyle(color: Colors.deepOrange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(144, 148, 201, 241),
              Color.fromARGB(143, 248, 146, 87)
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 370,
            height: 600,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color.fromARGB(255, 211, 119, 44), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepOrange.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
              child: Column(
                children: [
                  const Text(
                    "Member Information",
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameCon,
                            decoration: _textFieldDecoration("Name"),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _phoneCon,
                            keyboardType: TextInputType.phone,
                            decoration: _textFieldDecoration("Phone"),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _batchCon,
                            decoration: _textFieldDecoration("Batch"),
                          ),
                          const SizedBox(height: 15),
                          Obx(() => DropdownButtonFormField<String>(
                                value: selectedGender.value.isEmpty
                                    ? null
                                    : selectedGender.value,
                                decoration: _textFieldDecoration("Gender"),
                                items: genders.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    selectedGender.value = value!,
                              )),
                          const SizedBox(height: 15),
                          Obx(() => DropdownButtonFormField<String>(
                                value: selectedShirtSize.value.isEmpty
                                    ? null
                                    : selectedShirtSize.value,
                                decoration: _textFieldDecoration("Shirt Size"),
                                items: shirtSizes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    selectedShirtSize.value = value!,
                              )),
                          const SizedBox(height: 15),
                          Obx(() => DropdownButtonFormField<String>(
                                value: selectedDept.value.isEmpty
                                    ? null
                                    : selectedDept.value,
                                decoration: _textFieldDecoration("Department"),
                                items: departments.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    selectedDept.value = value!,
                              )),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _cfCon,
                            decoration:
                                _textFieldDecoration("Codeforces Handle"),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _atcCon,
                            decoration: _textFieldDecoration("AtCoder Handle"),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _ccCon,
                            decoration: _textFieldDecoration("CodeChef Handle"),
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final token = await Tokenprocess.readToken();
                      // handle form submission
                      await Ontapprocesses.setUserDetails(
                          token: token['authToken'] ?? "",
                          name: _nameCon.text,
                          phone: _phoneCon.text,
                          gender: selectedGender.string,
                          shirt: selectedShirtSize.string,
                          batch: _batchCon.text,
                          dept: selectedDept.string,
                          cfhandle: _cfCon.text.isEmpty ? "" : _cfCon.text,
                          atchandle: _atcCon.text.isEmpty ? "" : _atcCon.text,
                          cchandle: _ccCon.text.isEmpty ? "" : _ccCon.text,
                          slug: token['slug'] ?? "");
                      Get.offAll(HomePage());
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Proceed",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      backgroundColor: Color.fromARGB(255, 240, 240, 240),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Back",
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Home  |  "),
                      GestureDetector(
                        onTap: () => Get.offNamed('/login'),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
