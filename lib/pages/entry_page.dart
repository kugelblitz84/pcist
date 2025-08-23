import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import 'package:pcist/config/userConfig.dart';
//import 'package:pcist/widgets/fade_slide_in.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: isLandscape ? 16 : 40),
        Text(
          'Welcome to PCIST - Where Innovation Meets Code!', //this text has a weird font and underline
          style: TextStyle(
            color: Colors.white,
            fontSize: isLandscape ? 22 : 30,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isLandscape ? 6 : 10),
        Center(
          child: Text(
            'Join us to learn, practice, and grow together!', //this text has a weird font and underline
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 254, 254),
              fontSize: isLandscape ? 14 : 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: isLandscape ? 12 : 20),
        if (!UserConfig.isSignedIn.value)
          ElevatedButton(
            onPressed: () => Get.toNamed('/login'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(
              "Get Started", //this text is fine.
              style: TextStyle(color: Colors.white),
            ),
          ),
        // Push the chevron to the bottom without forcing overflow in landscape
        const Spacer(),
        Bounce(
          infinite: true,
          child: Icon(LucideIcons.chevronDown, color: Colors.white, size: 32),
        ),
        SizedBox(height: Get.height * 0.05),
      ],
    );
  }
}
