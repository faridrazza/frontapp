import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontapp/core/services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const EditProfileScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _nativeLanguageController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userProfile['name']);
    _phoneController = TextEditingController(text: widget.userProfile['phoneNumber']);
    _nativeLanguageController = TextEditingController(text: widget.userProfile['nativeLanguage']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nativeLanguageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField('Name', _nameController),
                  SizedBox(height: 16),
                  _buildTextField('Phone number', _phoneController),
                  SizedBox(height: 16),
                  _buildTextField('Native Language', _nativeLanguageController),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: Text('Save changes', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC6F432), // Changed from primary to backgroundColor
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC6F432), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC6F432), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      cursorColor: Color(0xFFA4FF70),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedProfile = await _apiService.updateProfile(
          name: _nameController.text,
          phoneNumber: _phoneController.text,
          nativeLanguage: _nativeLanguageController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          widget.userProfile['name'] = updatedProfile['name'];
          widget.userProfile['phoneNumber'] = updatedProfile['phoneNumber'];
          widget.userProfile['nativeLanguage'] = updatedProfile['nativeLanguage'];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }
}