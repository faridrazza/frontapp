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
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
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
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withOpacity(0.7),
                    Colors.purple.withOpacity(0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 0.7, 1.0],
                ),
              ),
              child: const Center(
                child: Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}