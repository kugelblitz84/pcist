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
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;
    final w = Get.width;
    final h = Get.height;
    final titleSize = isLandscape
        ? (w * 0.05).clamp(20, 26)
        : (w * 0.075).clamp(26, 34);
    final subtitleSize = isLandscape
        ? (w * 0.032).clamp(12, 14)
        : (w * 0.038).clamp(14, 16);
    final topGap = isLandscape
        ? (h * 0.02).clamp(12, 20)
        : (h * 0.05).clamp(24, 48);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: topGap.toDouble()),
        Text(
          'Welcome to PCIST - Where Innovation Meets Code!', //this text has a weird font and underline
          style: TextStyle(
            color: Colors.white,
            fontSize: titleSize.toDouble(),
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
              fontSize: subtitleSize.toDouble(),
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
