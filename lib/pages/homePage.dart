import 'package:flutter/material.dart';
import 'package:pcist/pages/entry_page.dart';
import 'package:pcist/pages/about_us.dart';
import 'package:pcist/pages/eventPages/contestTrackerPage.dart';
import 'package:pcist/pages/eventPages/events.dart';
//import 'package:get/get.dart';
import 'package:pcist/widgets/appBar.dart';
import 'package:pcist/widgets/animated_drawer.dart';
import 'package:pcist/widgets/fade_slide_in.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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

  void callBackToggleDrawer() => setState(() => drawerOpen = !drawerOpen);
  void callbackJumpToPage(int index) =>
      setState(() => _pageController.jumpToPage(index));

  Widget build(BuildContext context) {
    return Column(
      children: [
        //buffer
        //SizedBox(height: 10),
        // appbar
        // CustomAppBar(),
        //SizedBox(height: 23),
        SafeArea(
          child: appBar(callback: callBackToggleDrawer, open: drawerOpen),
          bottom: false,
          left: false,
          right: false,
        ),
        //body
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (drawerOpen) {
                callBackToggleDrawer();
              }
            },
            child: Stack(
              children: [
                //back ground image
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
                SizedBox.expand(
                  child: Container(color: Colors.black.withAlpha(170)),
                ),
                //scrollable pages
                PageView(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  pageSnapping: true,
                  children: [
                    FadeSlideIn(
                      delay: Duration(milliseconds: 400),
                      child: EntryPage(),
                    ),
                    FadeSlideIn(
                      delay: Duration(milliseconds: 400),
                      child: AboutUs(),
                    ),
                    FadeSlideIn(
                      delay: Duration(milliseconds: 400),
                      child: Events(),
                    ),
                    FadeSlideIn(
                      delay: Duration(milliseconds: 400),
                      child: ContestTrackerPage(), // new page
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  child: AnimatedDrawer(
                    isOpen: drawerOpen,
                    callback: callbackJumpToPage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
