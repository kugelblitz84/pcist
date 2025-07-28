import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/config/userConfig.dart';
import 'package:pcist/pages/homePage.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: (UserConfig.isLoading) == true
            ? Center(child: CircularProgressIndicator())
            : HomePage(),
      ),
    );
  }
}
