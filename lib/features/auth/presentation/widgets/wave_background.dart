import 'package:flutter/material.dart';

class WaveBackground extends StatelessWidget {
  final Widget child;

  const WaveBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 10,
          bottom: MediaQuery.of(context).size.height * 0.4,
          child: Image.asset(
            'assets/images/waveright.png',
            height: MediaQuery.of(context).size.height * 0.2,
          ),
        ),
        Positioned(
          right: 10,
          bottom: MediaQuery.of(context).size.height * 0.35,
          child: Image.asset(
            'assets/images/waveleft.png',
            
            height: MediaQuery.of(context).size.height * 0.28,
          ),
        ),
        child,
      ],
    );
  }
}
