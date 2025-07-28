import 'package:flutter/material.dart';
import 'package:pcist/secret.dart';
import 'package:get/get.dart';

class Userdashboard extends StatelessWidget {
  const Userdashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.125),
            ElevatedButton(
              onPressed: () => Get.toNamed('/setEvent'),
              child: Text('Set Event'),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed('/userListPage'),
              child: Text('Manage Users'),
            ),
            Text(
              "${LoggedInUserData.classroll ?? "null"}  has been logged in\n name: ${LoggedInUserData.name}",
            ),
          ],
        ),
      ),
    );
  }
}
