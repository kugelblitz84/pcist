import 'package:flutter/material.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:pcist/secret.dart';
import 'package:get/get.dart';
//import 'package:get/get.dart';

class OTPpage extends StatelessWidget {
  final TextEditingController _pinController = TextEditingController();

  OTPpage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = Get.width;
    final h = Get.height;
    final scaleW = w / 390.0;
    final scaleH = h / 844.0;
    final double scale = (scaleW < scaleH ? scaleW : scaleH)
        .clamp(0.8, 1.25)
        .toDouble();
    final double boxWidth = (w * 0.9).clamp(300.0, 520.0);
    final double headingSize = (18 * scale).clamp(16.0, 22.0);
    final double subHeadingSize = (14 * scale).clamp(12.0, 18.0);
    final double buttonFontSize = (17 * scale).clamp(15.0, 21.0);
    final double horizontalPad = (30 * scale).clamp(18.0, 40.0);
    final double verticalPad = (30 * scale).clamp(16.0, 36.0);
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
          child: Container(
            width: boxWidth,
            padding: EdgeInsets.symmetric(
              vertical: verticalPad,
              horizontal: horizontalPad,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Color.fromARGB(255, 211, 119, 44),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logos/download.png', height: 60),
                    const SizedBox(width: 20),
                    Image.asset('assets/images/download.png', height: 60),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Email Verification",
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: headingSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Enter the 6-digit code sent to your email",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subHeadingSize,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 2,
                    fontSize: (20 * scale).clamp(16.0, 24.0),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter PIN',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: Colors.deepOrange,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: Colors.deepOrange,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await Ontapprocesses.VerifyOtpProcess(_pinController.text);
                    // Call your verification logic here
                    print("Verifying: ${_pinController.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: Text(
                    "Verify",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: buttonFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: TextStyle(
                        fontSize: (14 * scale).clamp(12.0, 16.0),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final email = LoggedInUserData.email;
                        if (email == null || email.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'No email available to resend code.',
                          );
                          return;
                        }
                        await Ontapprocesses.sendForGotPassMail(mail: email);
                      },
                      child: Text(
                        "Resend",
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
