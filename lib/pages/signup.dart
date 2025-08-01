// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';

class SignUp extends StatelessWidget {
  SignUp({super.key});
  int _classRoll = 0;
  String classroll = "", password = "", email = "";
  final _classrollController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController();
  //final TextEditingController _controller = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(144, 148, 201, 241),
              Color.fromARGB(143, 248, 146, 87),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        //color: Colors.black,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color.fromARGB(255, 211, 119, 44),
                  width: 4,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 45,
                ),
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
                      "Signup Your Account",
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
                            controller: _classrollController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              focusColor: Colors.deepOrange,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.deepOrange,
                                ),
                              ),
                              labelText: 'Class Roll',
                              floatingLabelStyle: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                              border: const UnderlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _classRoll = int.tryParse(value) ?? 0;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _classRoll++;
                            _classrollController.text = _classRoll.toString();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (_classRoll > 0) {
                              _classRoll--;
                              _classrollController.text = _classRoll.toString();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: TextField(
                    //         controller: _controller,
                    //         keyboardType: TextInputType.number,
                    //         decoration: InputDecoration(
                    //           focusColor: Colors.deepOrange,
                    //           focusedBorder: UnderlineInputBorder(
                    //             borderSide:
                    //                 BorderSide(color: Colors.deepOrange),
                    //           ),
                    //           labelText: 'Batch',
                    //           floatingLabelStyle: TextStyle(
                    //             color: Colors.deepOrange,
                    //             fontSize: 19,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //           border: const UnderlineInputBorder(),
                    //         ),
                    //         onChanged: (value) {
                    //           _classRoll = int.tryParse(value) ?? 0;
                    //         },
                    //       ),
                    //     ),
                    //     IconButton(
                    //       icon: Icon(Icons.add),
                    //       onPressed: () {
                    //         _classRoll++;
                    //         _controller.text = _classRoll.toString();
                    //       },
                    //     ),
                    //     const SizedBox(height: 15),
                    //     IconButton(
                    //       icon: Icon(Icons.remove),
                    //       onPressed: () {
                    //         if (_classRoll > 0) {
                    //           _classRoll--;
                    //           _controller.text = _classRoll.toString();
                    //         }
                    //       },
                    //     ),
                    //   ],
                    // ),
                    TextField(
                      controller: _emailController,
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
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        focusColor: Colors.deepOrange,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        labelText: 'Password',
                        floatingLabelStyle: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                        border: const UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () async {
                        // signup process

                        Ontapprocesses.SignupProcess(
                          _emailController.text,
                          _passwordController.text,
                          _classrollController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text(
                        "Proceed",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        backgroundColor: const Color.fromARGB(
                          255,
                          199,
                          199,
                          199,
                        ),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text("Home  |  "),
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed('/login'),
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                      ],
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
}
