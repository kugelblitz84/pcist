import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  final List<String> companyLogos = [
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
    return Column(
      children: [
        // Video Section
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color.fromARGB(58, 255, 255, 255),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_fill,
                color: const Color.fromARGB(255, 3, 3, 3),
                size: 50,
              ),
            ),
          ),
        ),
        // About Us Section
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About Us",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Founded in 2007, pcIST is a thriving programming club dedicated to nurturing the next generation of tech enthusiasts. "
                "Based in Institute of Science and Technology, Dhanmondi, we are passionate about empowering students with the skills "
                "and knowledge they need to excel in the world of programming and technology...",
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 255, 253, 253),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the full About Us page or expand text
                  Get.toNamed('/AboutUsFull');
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('Read More'),
              ),
            ],
          ),
        ),
        // Alumni Section Title
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Alumni from IST are working in these companies",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(221, 255, 254, 254),
            ),
          ),
        ),
        // Carousel Slider for Logos
        CarouselSlider(
          items: companyLogos.map((logo) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(logo, fit: BoxFit.contain, height: 70),
            );
          }).toList(),
          options: CarouselOptions(
            height: 75,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 2),
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
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
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
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
      ],
    );
  }
}
