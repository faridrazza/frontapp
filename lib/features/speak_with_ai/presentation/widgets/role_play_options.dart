import 'package:flutter/material.dart';

class RolePlayOptions extends StatelessWidget {
  final Function(String) onSelectRolePlay;

  const RolePlayOptions({Key? key, required this.onSelectRolePlay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Please select one of the following role plays:',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        SizedBox(height: 16),
        _buildOptionTile('Interview', Icons.work, Color(0xFFFFA726)),
        _buildOptionTile('Catch up with friend', Icons.people, Color(0xFF66BB6A)),
        _buildOptionTile('My own scenario', Icons.create, Color(0xFF29B6F6)),
        _buildOptionTile('Ordering coffee', Icons.local_cafe, Color(0xFFEF5350)),
        _buildOptionTile('Asking directions', Icons.map, Color(0xFF9C27B0)),
        _buildOptionTile('AI chose a roleplay', Icons.auto_awesome, Color(0xFF7E57C2)),
      ],
    );
  }

  Widget _buildOptionTile(String title, IconData icon, Color color) {
    return Card(
      color: Colors.grey[900],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: TextStyle(color: Colors.white)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () => onSelectRolePlay(title),
      ),
    );
  }
}