import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pcist/config/userConfig.dart';

class AboutUsFull extends StatelessWidget {
  const AboutUsFull({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          const SizedBox(height: 13),
          _buildHeader(),
          _buildIntroText(),
          _buildWhatWeOffer(),
          const SizedBox(height: 30),
          _buildTitle("EVENTS GALLERY"),
          const SizedBox(height: 10),
          // _buildGalleryGrid(galleryImages),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              "Join us to learn, practice, and grow together",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          if (!UserConfig.isSignedIn.value)
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text(
                  "Get Started",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: Get.height * 0.3,
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Image.asset(
                'assets/images/aboutImage-B-sl_FO2.jpg',
                fit: BoxFit.cover,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                cacheHeight: 400,
              );
            },
          ),
          Container(color: Colors.black.withAlpha(160)),
          Positioned(
            top: Get.height * 0.14,
            left: Get.width * 0.35,
            child: const Text(
              "About Us",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: Get.height * 0.19,
            left: Get.width * 0.25,
            child: const Text(
              "What we are all about",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroText() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "Founded in 2007, pcIST is a thriving programming club committed to fostering a community of passionate coders and technology enthusiasts. Based at the Institute of Science and Technology, Dhanmondi, we strive to equip students with the essential skills, knowledge, and confidence to excel in the ever-evolving world of programming and technology. At pcIST, we believe in learning through experience. We organize a diverse range of activities, including hands-on coding workshops, competitive programming contests, technical seminars, and exciting tech fests. These initiatives create a dynamic environment where students can enhance their problem-solving skills, collaborate with like-minded peers, and stay ahead of emerging technologies. Whether you're a beginner taking your first steps into programming or an experienced coder looking to sharpen your skills, pcIST welcomes you to be a part of this journey of innovation and growth. Together, we code, compete, and create the future!",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildWhatWeOffer() {
    return Column(
      children: const [
        Text(
          "WHAT WE OFFER",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 6),
        Divider(
          thickness: 2,
          indent: 40,
          endIndent: 40,
          color: Colors.deepOrange,
        ),
        SizedBox(height: 20),
        CourseCard(
          title: "PROVIDE COURSES",
          description:
              "We offer courses, seminars, and workshops on competitive programming, DSA, and more.",
          icon: Icons.school,
        ),
        SizedBox(height: 10),
        CourseCard(
          title: "ARRANGE CONTESTS",
          description:
              "We host on-campus contests to sharpen problem-solving skills and prepare for competitions.",
          icon: FontAwesomeIcons.brain,
        ),
        SizedBox(height: 10),
        CourseCard(
          title: "IUPC & ICPC PARTICIPATIONS",
          description:
              "We send top programmers to represent pcIST in national and international competitions.",
          icon: FontAwesomeIcons.trophy,
        ),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Center(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: Get.width * 0.75,
            color: Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    Widget contactRow({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.deepOrange, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CONTACT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 2, width: 100, color: Colors.deepOrange),
              const SizedBox(height: 16),
              contactRow(
                icon: Icons.phone,
                label: 'Phone',
                value: '+880 123 456 789',
              ),
              contactRow(
                icon: Icons.email,
                label: 'Email',
                value: 'info@club.com',
              ),
              contactRow(
                icon: Icons.location_on,
                label: 'Address',
                value: '123 Club Street, Dhaka, Bangladesh',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GalleryImage extends StatelessWidget {
  final String path;
  const GalleryImage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        cacheHeight: 300,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title, description;
  final IconData icon;
  const CourseCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 325,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(139, 126, 124, 124)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.deepOrange, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(221, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
