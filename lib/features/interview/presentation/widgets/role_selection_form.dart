import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionForm extends StatefulWidget {
  final Function(String role, String experienceLevel) onSubmit;

  const RoleSelectionForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _RoleSelectionFormState createState() => _RoleSelectionFormState();
}

class _RoleSelectionFormState extends State<RoleSelectionForm> {
  String? selectedRole;
  String? selectedExperience;

  final List<String> roles = [
    'Software Engineer',
    'Data Scientist',
    'Product Manager',
    'UX Designer',
    'DevOps Engineer',
    'Marketing Manager',
    'Sales Representative',
    'Business Analyst',
  ];

  final List<String> experienceLevels = [
    'Fresher',
    'Experienced',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFC8F235), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose Your Role',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC8F235),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRole,
                hint: Text('Select Role', style: TextStyle(color: Colors.grey)),
                isExpanded: true,
                dropdownColor: Colors.black,
                style: TextStyle(color: Colors.white),
                items: roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Experience Level',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC8F235),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: experienceLevels.map((level) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedExperience = level;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedExperience == level
                            ? Color(0xFFC8F235)
                            : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedExperience == level
                              ? Color(0xFFC8F235)
                              : Colors.grey[800]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          level,
                          style: TextStyle(
                            color: selectedExperience == level
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (selectedRole != null && selectedExperience != null)
                  ? () => widget.onSubmit(selectedRole!, selectedExperience!)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC8F235),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Start Interview',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
