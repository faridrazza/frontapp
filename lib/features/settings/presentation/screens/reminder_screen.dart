import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  DateTime _selectedTime = DateTime.now();
  bool _isAM = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackgroundDesign(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  _buildHeader(),
                  Spacer(),
                  _buildTimePicker(),
                  SizedBox(height: 40),
                  _buildSetButton(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDesign() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPainter(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What is the good time?',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        Text(
          'We will send you daily reminders to practice.',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.black,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFC6F432).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimeColumn(true),  // Hours
          Text(':', style: GoogleFonts.inter(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          _buildTimeColumn(false),  // Minutes
          _buildAMPMToggle(),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(bool isHour) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.keyboard_arrow_up, color: Color(0xFFC6F432), size: 36),
          onPressed: () => _adjustTime(isHour, true),
        ),
        Text(
          isHour 
              ? _selectedTime.hour.toString().padLeft(2, '0') 
              : _selectedTime.minute.toString().padLeft(2, '0'),
          style: GoogleFonts.inter(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFFC6F432), size: 36),
          onPressed: () => _adjustTime(isHour, false),
        ),
      ],
    );
  }

  void _adjustTime(bool isHour, bool increment) {
    setState(() {
      if (isHour) {
        _selectedTime = _selectedTime.add(Duration(hours: increment ? 1 : -1));
      } else {
        _selectedTime = _selectedTime.add(Duration(minutes: increment ? 1 : -1));
      }
      _isAM = _selectedTime.hour < 12;
    });
  }

  Widget _buildAMPMToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildAMPMButton('AM'),
          _buildAMPMButton('PM'),
        ],
      ),
    );
  }

  Widget _buildAMPMButton(String label) {
    bool isSelected = (label == 'AM' && _isAM) || (label == 'PM' && !_isAM);
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAM = label == 'AM';
          if (_isAM && _selectedTime.hour >= 12) {
            _selectedTime = _selectedTime.subtract(Duration(hours: 12));
          } else if (!_isAM && _selectedTime.hour < 12) {
            _selectedTime = _selectedTime.add(Duration(hours: 12));
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFC6F432) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSetButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement set reminder logic
      },
      child: Text(
        'Set Reminder',
        style: GoogleFonts.inter(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC6F432),
        padding: EdgeInsets.symmetric(vertical: 16),
        minimumSize: Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: Color(0xFFC6F432).withOpacity(0.5),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final wavePaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.35,
          size.width * 0.5, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.25,
          size.width, size.height * 0.3)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}