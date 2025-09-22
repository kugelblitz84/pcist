// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int _classRoll = 0;
  String prcd = "Register";
  String classroll = "", password = "", email = "";
  bool _showPassword = false;

  final _classrollController = TextEditingController(),
      _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  //final TextEditingController _controller = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    final w = Get.width;
    // Scale relative to common phone width (~390). Clamp to avoid extremes.
    final double scale = (w / 390.0).clamp(0.8, 1.25).toDouble();
    double boxWidth = (w * 0.9).clamp(300.0, 520.0);
    final double headingSize = (18 * scale).clamp(16.0, 22.0);
    final double labelSize = (19 * scale).clamp(15.0, 22.0);
    final double buttonFontSize = (18 * scale).clamp(16.0, 22.0);
    final double backFontSize = (19 * scale).clamp(16.0, 22.0);
    final double horizontalPad = (45 * scale).clamp(22.0, 60.0);
    final double verticalPad = (20 * scale).clamp(12.0, 30.0);
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
              width: boxWidth,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color.fromARGB(255, 211, 119, 44),
                  width: 4,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: verticalPad,
                  horizontal: horizontalPad,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logos/download.png',
                          height: (60 * scale).clamp(44.0, 68.0),
                        ),
                        const SizedBox(width: 20),
                        Image.asset(
                          'assets/images/download.png',
                          height: (60 * scale).clamp(44.0, 68.0),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Signup Your Account",
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: headingSize,
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
                                fontSize: labelSize,
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
                          fontSize: labelSize,
                          fontWeight: FontWeight.bold,
                        ),
                        border: const UnderlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        focusColor: Colors.deepOrange,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepOrange),
                        ),
                        labelText: 'Password',
                        floatingLabelStyle: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: labelSize,
                          fontWeight: FontWeight.bold,
                        ),
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.deepOrange,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                          tooltip: _showPassword
                              ? 'Hide password'
                              : 'Show password',
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () async {
                        // Validate password length
                        if ((_passwordController.text).length < 8) {
                          Get.snackbar(
                            'Weak password',
                            'Password must be at least 8 characters long.',
                          );
                          return;
                        }
                        // signup process
                        setState(() => prcd = "Registering..");
                        Ontapprocesses.SignupProcess(
                          _emailController.text,
                          _passwordController.text,
                          _classrollController.text,
                        );
                        setState(() => prcd = "Register");
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        backgroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: Text(
                        prcd,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: buttonFontSize,
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
                      child: Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: backFontSize,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            "Home  |  ",
                            style: TextStyle(
                              fontSize: (14 * scale).clamp(12.0, 16.0),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed('/login'),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: (14 * scale).clamp(12.0, 16.0),
                            ),
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
