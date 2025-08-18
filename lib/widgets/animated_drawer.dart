import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:pcist/config/userConfig.dart';
import 'package:pcist/preocesses/onTapProcesses.dart';
import 'package:pcist/widgets/fade_slide_in.dart';

//import 'package:get/get.dart';

class AnimatedDrawer extends StatefulWidget {
  final bool isOpen;
  final void Function(int index) callback;
  const AnimatedDrawer({
    super.key,
    required this.isOpen,
    required this.callback,
  });

  @override
  State<AnimatedDrawer> createState() => _AnimatedDrawerState();
}

class _AnimatedDrawerState extends State<AnimatedDrawer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> size;
  // final height = Get.hegiht;
  // final width = Get.width;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    size = Tween<double>(
      begin: 0,
      end: UserConfig.isSignedIn.value ? 300 : 250,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Container(
        color: Colors.black,
        height: size.value,
        width: 170,
        child: size.value >= (UserConfig.isSignedIn.value ? 300 : 250)
            ? Obx(() {
                return Column(
                  children: [
                    FadeSlideIn(
                      delay: Duration(milliseconds: 0),
                      child: DrawerTile(
                        title: 'Home',
                        fun: () => widget.callback(0),
                      ),
                    ),
                    FadeSlideIn(
                      delay: Duration(milliseconds: 50),
                      child: DrawerTile(
                        title: 'About Us',
                        fun: () => widget.callback(1),
                      ),
                    ),
                    FadeSlideIn(
                      delay: Duration(milliseconds: 100),
                      child: DrawerTile(
                        title: 'Events',
                        fun: () => widget.callback(2),
                      ),
                    ),
                    FadeSlideIn(
                      delay: Duration(milliseconds: 200),
                      child: DrawerTile(
                        title: 'Contest tracker',
                        fun: () => widget.callback(3),
                      ),
                    ),
                    if (UserConfig.isSignedIn.value)
                      FadeSlideIn(
                        delay: Duration(milliseconds: 150),
                        child: DrawerTile(
                          title: 'Log Out',
                          fun: () => Ontapprocesses.logOut(),
                        ),
                      ),

                    // FadeSlideIn(
                    //   delay: Duration(milliseconds: 160),
                    //   child: DrawerTile(
                    //     title: 'Contact',
                    //     fun: () => widget.callback(4),
                    //   ),
                    // ),
                  ],
                );
              })
            : null,
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final String title;
  final VoidCallback fun;
  const DrawerTile({super.key, required this.title, required this.fun});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(
          title,
          textAlign: TextAlign.end,
          style: TextStyle(color: Colors.white),
        ),
        onTap: fun,
      ),
    );
  }
}
