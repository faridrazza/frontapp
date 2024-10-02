import 'package:flutter/material.dart';

class GameSetupForm extends StatefulWidget {
  final Function(String, String?) onSubmit;

  GameSetupForm({required this.onSubmit});

  @override
  _GameSetupFormState createState() => _GameSetupFormState();
}

class _GameSetupFormState extends State<GameSetupForm> {
  String _selectedLevel = 'Easy';
  String? _selectedTimer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedLevel,
            decoration: InputDecoration(labelText: 'Game Level'),
            items: ['Easy', 'Medium', 'Hard']
                .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                .toList(),
            onChanged: (value) => setState(() => _selectedLevel = value!),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTimer,
            decoration: InputDecoration(labelText: 'Timer'),
            items: [
              DropdownMenuItem(value: null, child: Text('No Timer')),
              ...['10', '15', '30']
                  .map((timer) => DropdownMenuItem(value: timer, child: Text('$timer seconds')))
                  .toList(),
            ],
            onChanged: (value) => setState(() => _selectedTimer = value),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            child: Text('Start Game'),
            onPressed: () => widget.onSubmit(_selectedLevel, _selectedTimer),
          ),
        ],
      ),
    );
  }
}
