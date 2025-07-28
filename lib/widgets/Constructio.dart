import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Construction_text extends StatefulWidget {
  const Construction_text({super.key});

  @override
  State<Construction_text> createState() => _Construction_textState();
}

class _Construction_textState extends State<Construction_text>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(); // Infinite loop

    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right edge
      end: const Offset(-1.0, 0.0), // Move to left edge
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: double.infinity,
      color: Colors.deepOrange,
      child: ClipRect(
        child: SlideTransition(
          position: _animation,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "🚧🚧 Under Construction 🚧🚧",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
