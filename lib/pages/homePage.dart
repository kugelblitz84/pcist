import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pcist/config/userConfig.dart';
import 'package:pcist/pages/notfiications_pages.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:pcist/pages/homeSections/entry_page.dart';
import 'package:pcist/pages/homeSections/about_us.dart';
import 'package:pcist/pages/homeSections/contestTrackerPage.dart';
import 'package:pcist/pages/homeSections/events.dart';
import 'package:pcist/widgets/fade_slide_in.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _pageOffset = 0;
  late bool drawerOpen;
  final List<String> images = [
    'assets/images/hero-CNNTwE-V.jpg',
    'assets/images/aboutImage-B-sl_FO2.jpg',
    'assets/images/DJI_0312 (1).jpg',
    'assets/images/5594016.jpg',
  ];
  final PageController _pageController = PageController();
  @override
  void initState() {
    super.initState();
    drawerOpen = false;
    //print("user signed:  ${userConfig.isSignedIn.value}");
    _pageController.addListener(() {
      setState(() {
        _pageOffset = (_pageController.page ?? 0).round();
        //print(_pageOffset);
      });
    });
  }

  void _openEndDrawer() => _scaffoldKey.currentState?.openEndDrawer();
  void _closeEndDrawer() => Navigator.of(context).maybePop();
  void callbackJumpToPage(int index) {
    _closeEndDrawer();
    _pageController.jumpToPage(index);
  }

  Future<bool> _hasUnread() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("hasUnread") ?? false;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      onEndDrawerChanged: (open) => setState(() => drawerOpen = open),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.black,
        titleSpacing: 0,
        leadingWidth: 60,
        leading: SizedBox(
          height: 60,
          width: 60,
          child: Hero(
            tag: 'app-logo',
            child: Image.asset('assets/images/download.png', fit: BoxFit.cover),
          ),
        ),
        title: const SizedBox.shrink(),
        actions: [
          // Chat now available to all signed-in users
          Obx(() {
            if (!UserConfig.isSignedIn.value) return const SizedBox.shrink();
            return Row(
              children: [
                IconButton(
                  onPressed: () => Get.toNamed('/chat'),
                  icon: const Icon(Icons.message, color: Colors.white),
                  tooltip: 'Chat',
                ),
                const SizedBox(width: 8),
              ],
            );
          }),
          // Auth-dependent items
          Obx(() {
            if (!UserConfig.isSignedIn.value) {
              return Row(
                children: [
                  _NavTextButton('Login', () => Get.toNamed('/login')),
                  const SizedBox(width: 15),
                  _NavTextButton('Register', () => Get.toNamed('/signup')),
                  const SizedBox(width: 12),
                ],
              );
            }
            return Row(
              children: [
                _NavTextButton('Profile', () => Get.toNamed('/dashBoard')),
                const SizedBox(width: 10),
                _NotificationIcon(
                  checkUnread: _hasUnread,
                  onOpen: () async {
                    await Get.to(() => const NotificationsPage());
                    setState(() {});
                  },
                ),
                const SizedBox(width: 12),
              ],
            );
          }),
          // End-drawer toggle
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 1),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(6),
              ),
              onPressed: () {
                if (drawerOpen) {
                  _closeEndDrawer();
                } else {
                  _openEndDrawer();
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: ScaleTransition(scale: anim, child: child),
                ),
                child: Icon(
                  drawerOpen ? Icons.close : Icons.menu,
                  key: ValueKey<bool>(drawerOpen),
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: LayoutBuilder(
        builder: (context, constraints) {
          final double topInset =
              kToolbarHeight + MediaQuery.of(context).padding.top;
          return Container(
            margin: EdgeInsets.only(top: topInset),
            width: 220,
            height: Get.height,
            child: Drawer(
              backgroundColor: Colors.black,
              child: SafeArea(
                child: Obx(() {
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // Drawer header with hero logo to mimic custom animation
                      Padding(
                        padding: const EdgeInsets.only(right: 12, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 48,
                            width: 48,
                            child: Image.asset(
                              'assets/images/download.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Admin Features always visible for signed-in users
                      if (UserConfig.isSignedIn.value)
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 0),
                          child: _DrawerTile(
                            title: 'Admin Features',
                            onTap: () {
                              _closeEndDrawer();
                              Get.toNamed('/adminFeatures');
                            },
                          ),
                        ),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 0),
                        child: _DrawerTile(
                          title: 'Home',
                          onTap: () => callbackJumpToPage(0),
                        ),
                      ),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 50),
                        child: _DrawerTile(
                          title: 'About Us',
                          onTap: () => callbackJumpToPage(1),
                        ),
                      ),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: _DrawerTile(
                          title: 'Events',
                          onTap: () => callbackJumpToPage(2),
                        ),
                      ),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 180),
                        child: _DrawerTile(
                          title: 'Contest tracker',
                          onTap: () => callbackJumpToPage(3),
                        ),
                      ),
                      if (UserConfig.isSignedIn.value)
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 290),
                          child: _DrawerTile(
                            title: 'Log Out',
                            onTap: () => Ontapprocesses.logOut(),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          );
        },
      ),
      body: Stack(
        children: [
          // background image
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.linear,
            switchOutCurve: Curves.linear,
            child: LayoutBuilder(
              key: ValueKey<String>(images[_pageOffset]),
              builder: (context, constraints) {
                return Image.asset(
                  images[_pageOffset],
                  fit: BoxFit.cover,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                );
              },
            ),
          ),
          // dark filter
          SizedBox.expand(child: Container(color: Colors.black.withAlpha(170))),
          // pages
          PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            pageSnapping: true,
            children: [
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: EntryPage(),
              ),
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: AboutUs(),
              ),
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: Events(),
              ),
              FadeSlideIn(
                delay: const Duration(milliseconds: 400),
                child: ContestTrackerPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _NavTextButton(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final Future<bool> Function() checkUnread;
  final VoidCallback onOpen;
  const _NotificationIcon({required this.checkUnread, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Stack(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.notifications, color: Colors.white, size: 26),
          ),
          FutureBuilder<bool>(
            future: checkUnread(),
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
}

class _DrawerTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _DrawerTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.end,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
