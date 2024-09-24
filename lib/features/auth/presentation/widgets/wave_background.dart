import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveBackground extends StatefulWidget {
  final Widget child;

  const WaveBackground({Key? key, required this.child}) : super(key: key);

  @override
  _WaveBackgroundState createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(
                  animation: _controller,
                  waveColor: Colors.blue.withOpacity(0.3),
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color waveColor;

  WavePainter({required this.animation, required this.waveColor}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    for (var i = 0.0; i < size.width; i++) {
      path.lineTo(
        i,
        math.sin((i / size.width * 2 * math.pi) + (animation.value * 2 * math.pi)) * 20 +
            size.height / 2,
      );
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}