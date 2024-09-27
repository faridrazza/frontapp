import 'package:flutter/material.dart';

class RolePlayOptions extends StatelessWidget {
  final Function(String) onSelectRolePlay;

  RolePlayOptions({required this.onSelectRolePlay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Container(
        width: 275,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Select one of the following roleplay:',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            _buildOptionWithDividers('Interview', '👔', Color(0xFFFFA500)),
            _buildOptionWithDividers('Catch up with friend', '👥', Color(0xFFFF69B4)),
            _buildOptionWithDividers('My own scenario', '💡', Color(0xFF00CED1)),
            _buildOptionWithDividers('Ordering coffee', '☕', Color(0xFF8B4513)),
            _buildOptionWithDividers('Asking directions', '🗺️', Color(0xFF9370DB)),
            _buildOptionWithDividers('AI chose a roleplay', '🤖', Color(0xFF32CD32), isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionWithDividers(String title, String emoji, Color color, {bool isLast = false}) {
    return Column(
      children: [
        _buildDivider(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: _buildOption(title, emoji, color),
        ),
        if (isLast) _buildDivider(),
      ],
    );
  }

  Widget _buildOption(String title, String emoji, Color color) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity(vertical: -2),
      leading: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Text(emoji, style: TextStyle(fontSize: 16)),
      ),
      title: Text(title, style: TextStyle(color: Colors.black, fontSize: 15)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 14),
      onTap: () => onSelectRolePlay(title),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.withOpacity(0.2),
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}