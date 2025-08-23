import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  final List<String> companyLogos = const [
    'assets/logos/bkash-Bye9swto.png',
    'assets/logos/microsoft-DfiWx0If.png',
    'assets/logos/robi-DPu_XohX.png',
    'assets/logos/trivago-DXdVsnjU.png',
    'assets/logos/tw-Dtd64rXS.png',
    'assets/logos/warner-396UrHMS.png',
    'assets/logos/welldev-wJZXTpmF.png',
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLandscape = media.orientation == Orientation.landscape;

    final w = Get.width;
    final h = Get.height;

    final double titleSize = isLandscape
        ? (w * 0.035).clamp(18.0, 22.0)
        : (w * 0.055).clamp(20.0, 26.0);
    final double bodySize = isLandscape
        ? (w * 0.028).clamp(12.0, 14.0)
        : (w * 0.036).clamp(14.0, 16.0);
    final EdgeInsets sectionPad = EdgeInsets.all(isLandscape ? 8 : 12);

    // Constrain sizes to avoid inner scrolling; use width in landscape for layout.
    final double videoH = isLandscape
        ? math.min(h * 0.22, 150)
        : math.min(h * 0.22, 190);
    final double logosCarouselH = isLandscape
        ? math.min(h * 0.12, 72)
        : math.min(h * 0.12, 84);
    final double logoHeight = logosCarouselH - 12;

    return Column(
      children: [
        if (isLandscape)
          Padding(
            padding: sectionPad,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video box
                Expanded(
                  child: SizedBox(
                    height: videoH,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(58, 255, 255, 255),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Color.fromARGB(255, 3, 3, 3),
                          size: 46,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Text box
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "About Us",
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Founded in 2007, pcIST is a thriving programming club dedicated to nurturing the next generation of tech enthusiasts. "
                        "Based in Institute of Science and Technology, Dhanmondi, we are passionate about empowering students with the skills "
                        "and knowledge they need to excel in the world of programming and technology...",
                        style: TextStyle(
                          fontSize: bodySize,
                          color: const Color.fromARGB(255, 255, 253, 253),
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/AboutUsFull'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Read More'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else ...[
          // Portrait: video on top then text
          Padding(
            padding: sectionPad,
            child: Container(
              height: videoH,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(58, 255, 255, 255),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Color.fromARGB(255, 3, 3, 3),
                  size: 52,
                ),
              ),
            ),
          ),
          Padding(
            padding: sectionPad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "About Us",
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Founded in 2007, pcIST is a thriving programming club dedicated to nurturing the next generation of tech enthusiasts. "
                  "Based in Institute of Science and Technology, Dhanmondi, we are passionate about empowering students with the skills "
                  "and knowledge they need to excel in the world of programming and technology...",
                  style: TextStyle(
                    fontSize: bodySize,
                    color: const Color.fromARGB(255, 255, 253, 253),
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/AboutUsFull'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Read More'),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: isLandscape ? 4 : 8),
        // Alumni Section Title
        Padding(
          padding: sectionPad,
          child: Text(
            "Alumni from IST are working in these companies",
            style: TextStyle(
              fontSize: isLandscape
                  ? (w * 0.04).clamp(16.0, 20.0)
                  : (w * 0.05).clamp(18.0, 22.0),
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(221, 255, 254, 254),
            ),
          ),
        ),
        // Carousel Slider for Logos
        CarouselSlider(
          items: companyLogos.map((logo) {
            return Padding(
              padding: EdgeInsets.all(isLandscape ? 6 : 8),
              child: Image.asset(logo, fit: BoxFit.contain, height: logoHeight),
            );
          }).toList(),
          options: CarouselOptions(
            height: logosCarouselH,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 2),
            enlargeCenterPage: true,
            onPageChanged: (index, reason) =>
                setState(() => _currentIndex = index),
          ),
        ),
        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: companyLogos.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 4.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? Colors.orange
                      : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
        if (isLandscape) const SizedBox(height: 4),
      ],
    );
  }
}
