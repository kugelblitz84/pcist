import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
//import 'package:pcist/widgets/fade_slide_in.dart';

class EntryPage extends StatelessWidget {
  const EntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40),
        const Text(
          'Welcome to PCIST \n Where Innovation Meets Code!', //this text has a weird font and underline
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Center(
          child: const Text(
            'Join us to learn, practice, and grow together!', //this text has a weird font and underline
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 254, 254),
              fontSize: 15,
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: Text(
            "Get Started", //this text is fine.
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: Get.height * 0.45),
        Bounce(
          infinite: true,
          child: Icon(LucideIcons.chevronDown, color: Colors.white, size: 32),
        ),
      ],
    );
  }
}
