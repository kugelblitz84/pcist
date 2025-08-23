import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pcist/secret.dart';
//import 'package:pcist/pages/homePage.dart';
import 'package:pcist/config/userConfig.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pcist/pages/notfiications_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class appBar extends StatefulWidget {
  final VoidCallback callback;
  final bool open;
  appBar({super.key, required this.callback, required this.open});

  @override
  State<appBar> createState() => _appBarState();
}

class _appBarState extends State<appBar> {
  //bool drawerOpen = false;
  Future<bool> _hasUnread() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("hasUnread") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.black, // App bar background
      //padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          SizedBox(
            height: 60, // same as app bar height
            width: 60, // match width proportionally to height
            child: Image.asset(
              'assets/images/download.png',
              fit: BoxFit.cover, // fills without border, may crop edges
            ),
          ),
          Obx(() {
            final showChat =
                UserConfig.isSignedIn.value && (LoggedInUserData.role == 2);
            if (!showChat) return const SizedBox.shrink();
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: IconButton(
                    onPressed: () => Get.toNamed('/chat'),
                    icon: const Icon(Icons.message),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 15),
              ],
            );
          }),
          Spacer(),
          // Menu Items
          Obx(() {
            return Row(
              children: [
                if (UserConfig.isSignedIn.value == false) ...[
                  _navText('Login', '/login'),
                  const SizedBox(width: 15),
                  _navText('Register', '/signup'),
                ] else ...[
                  _navText('Profile', '/dashBoard'),
                  const SizedBox(width: 10),
                  _notificationIcon(),
                ],

                const SizedBox(width: 15),

                // Drawer toggle
                _menuButton(),
              ],
            );
          }),
          SizedBox(width: 15),
        ],
      ),
    );
  }

  // Navigation Text Helper
  Widget _navText(String text, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  // Notification Icon Helper
  Widget _notificationIcon() {
    return GestureDetector(
      onTap: () async {
        await Get.to(() => const NotificationsPage());
        setState(() {});
      },
      child: Stack(
        children: [
          const Icon(Icons.notifications, color: Colors.white, size: 26),
          FutureBuilder<bool>(
            future: _hasUnread(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  // Menu Button Helper
  Widget _menuButton() {
    return GestureDetector(
      onTap: () => widget.callback(),
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Icon(
          widget.open ? LucideIcons.x : LucideIcons.menu,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
