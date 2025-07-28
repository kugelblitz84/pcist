import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:pcist/secret.dart';

class PassResetPage extends StatelessWidget {
  PassResetPage({super.key});
  final TextEditingController _mailController = TextEditingController();
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
        )),
        //color: Colors.black,
        child: Center(
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: const Color.fromARGB(255, 211, 119, 44), width: 4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 45),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logos/download.png', height: 60),
                      const SizedBox(width: 20),
                      Image.asset('assets/images/download.png', height: 60),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Enter your E-mail",
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mailController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            focusColor: Colors.deepOrange,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepOrange),
                            ),
                            labelText: 'Email',
                            floatingLabelStyle: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                            border: const UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      await Ontapprocesses.sendForGotPassMail(
                          mail: _mailController.text);
                      LoggedInUserData.email = _mailController.text;
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text("Send Code",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      backgroundColor: const Color.fromARGB(255, 199, 199, 199),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text("Back",
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 19)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class setNewPassPage extends StatelessWidget {
  setNewPassPage({super.key});
  final _pass = TextEditingController();
  final _reEnterPass = TextEditingController();
  final _code = TextEditingController();
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
        )),
        //color: Colors.black,
        child: Center(
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: const Color.fromARGB(255, 211, 119, 44), width: 4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 45),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logos/download.png', height: 60),
                      const SizedBox(width: 20),
                      Image.asset('assets/images/download.png', height: 60),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Login Your Account",
                    style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // TextField(
                  //   decoration: InputDecoration(
                  //     focusColor: Colors.deepOrange,
                  //     focusedBorder: UnderlineInputBorder(
                  //         borderSide: BorderSide(color: Colors.deepOrange)),
                  //     labelText: 'Class Roll',
                  //     floatingLabelStyle: TextStyle(
                  //         color: Colors.deepOrange,
                  //         fontSize: 19,
                  //         fontWeight: FontWeight.bold),
                  //     border: const UnderlineInputBorder(),
                  //   ),
                  // ),
                  TextField(
                    controller: _code,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusColor: Colors.deepOrange,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange),
                      ),
                      labelText: 'Enter Code',
                      floatingLabelStyle: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: _pass,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusColor: Colors.deepOrange,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange),
                      ),
                      labelText: 'Enter New Password',
                      floatingLabelStyle: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                      border: const UnderlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 5),
                  TextField(
                    controller: _reEnterPass,
                    decoration: InputDecoration(
                      focusColor: Colors.deepOrange,
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange)),
                      labelText: 'Re-type Password',
                      floatingLabelStyle: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 19,
                          fontWeight: FontWeight.bold),
                      border: const UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async {
                      if (_pass.text == _reEnterPass.text) {
                        Ontapprocesses.setNewPass(
                            mail: LoggedInUserData.email ?? "",
                            code: _code.text,
                            newPass: _pass.text);
                      } else {
                        Get.snackbar(
                            "Error", "The two passwords do not match!!");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      backgroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text("Login",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      backgroundColor: const Color.fromARGB(255, 199, 199, 199),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text("Back",
                        style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 19)),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Get.offNamed('/signup'),
                    child: Text(
                      "Create a new account",
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    child: Text("Forgot Password? "),
                    onTap: () => Get.to(PassResetPage()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
