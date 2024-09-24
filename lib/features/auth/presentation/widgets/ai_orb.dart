import 'package:flutter/material.dart';

class AiOrb extends StatefulWidget {
  const AiOrb({Key? key}) : super(key: key);

  @override
  _AiOrbState createState() => _AiOrbState();
}

class _AiOrbState extends State<AiOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Image.asset(
              'assets/images/aiorb.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}