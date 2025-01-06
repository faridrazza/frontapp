import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionForm extends StatefulWidget {
  final Function(String role, String experienceLevel) onSubmit;

  const RoleSelectionForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _RoleSelectionFormState createState() => _RoleSelectionFormState();
}

class _RoleSelectionFormState extends State<RoleSelectionForm> {
  final TextEditingController _roleController = TextEditingController();
  String? selectedExperience;

  final List<String> experienceLevels = [
    'Fresher',
    'Experienced',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFC8F235), width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Your Role',
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
                child: TextField(
                  controller: _roleController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g., Flutter Developer, Product Manager',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
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
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedExperience = level;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
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
                  );
                }).toList(),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_roleController.text.isNotEmpty &&
                          selectedExperience != null)
                      ? () => widget.onSubmit(
                          _roleController.text.trim(), selectedExperience!)
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }
}
