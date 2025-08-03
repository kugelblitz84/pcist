import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/secret.dart';
//import 'package:pcist/pages/homePage.dart';
import 'Constructio.dart';
import 'package:pcist/config/userConfig.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:lucide_icons/lucide_icons.dart';

class appBar extends StatefulWidget {
  final VoidCallback callback;
  late bool open;
  appBar({super.key, required this.callback, required this.open});

  @override
  State<appBar> createState() => _appBarState();
}

class _appBarState extends State<appBar> {
  //bool drawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 78,
        width: Get.width,
        child: Row(
          children: [
            // Logo section
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/images/download.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Menu and options
            Expanded(
              flex: 6,
              child: Container(
                color: Colors.black,
                child: Column(
                  children: [
                    Construction_text(),
                    Obx(
                      () => Row(
                        children: [
                          if (UserConfig.isSignedIn.value == true &&
                              LoggedInUserData.role == 2)
                            Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: IconButton(
                                iconSize: 30,
                                onPressed: () {
                                  Get.toNamed('/chat');
                                  // handle message button tap
                                },
                                icon: Icon(Icons.message, color: Colors.white),
                              ),
                            ),
                          Spacer(), // Push everything else to the right

                          if (UserConfig.isSignedIn.value == false)
                            GestureDetector(
                              onTap: () => Get.toNamed('/login'),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 7.0),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(width: 17),
                          if (UserConfig.isSignedIn.value == false)
                            GestureDetector(
                              onTap: () => Get.toNamed('/signup'),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 7.0),
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          if (UserConfig.isSignedIn.value == true) ...[
                            GestureDetector(
                              child: Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () => Get.toNamed('/dashBoard'),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () async {
                                await Ontapprocesses.logOut();
                              },
                            ),
                          ],
                          SizedBox(width: 17),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                //drawerOpen = !drawerOpen;
                                widget.callback();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                                right: 5,
                                bottom: 5,
                              ),
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1,
                                  ),
                                ),
                                child: AnimatedSwitcher(
                                  duration: Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                  child: Icon(
                                    widget.open
                                        ? LucideIcons.x
                                        : LucideIcons.menu,
                                    key: ValueKey<bool>(widget.open),
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
