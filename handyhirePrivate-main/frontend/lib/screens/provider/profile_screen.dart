import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ADDED
import '../../utils/app_colors.dart';
import '../../services/session_service.dart';
import '../../services/api_service.dart'; // ADDED: Required for API calls
import '../auth/login_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = true; 

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    try {
      // 1. Get email directly from SharedPreferences since SessionService is missing getEmail()
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email') ?? "provider@example.com";
      
      setState(() {
        _emailController.text = savedEmail; 
      });

      // 2. Try to fetch real data from backend
      try {
        final userProfile = await ApiService.instance.getProfile(savedEmail);
        setState(() {
          _nameController.text = userProfile['name'] ?? "Unknown User"; 
          _phoneController.text = "0712345678"; 
          _locationController.text = "Sri Lanka"; 
          _skillsController.text = "Cleaner"; 
          _experienceController.text = "5 years"; 
          _isLoading = false;
        });
      } catch (e) {
        // If backend fails (e.g., endpoint not ready), fallback to placeholder
        setState(() {
          _nameController.text = "User Data Not Found";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    await SessionService.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        if (_formKey.currentState!.validate()) {
          _isEditing = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } else {
        _isEditing = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Intercept the back button
      onPopInvoked: (bool didPop) {
        if (didPop) return;

        // This forces the app to go back to the Provider Home Screen, 
        // which automatically lands on the "Job Requests" tab.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false, 
          title: const Text('My Profile',
              style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: _toggleEdit,
              child: Text(_isEditing ? 'Save' : 'Edit',
                  style: const TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                      border: Border.all(color: AppColors.accent, width: 3),
                    ),
                    child: const Icon(Icons.person, size: 65, color: AppColors.accent),
                  ),
                  const SizedBox(height: 10),
                  if (!_isEditing)
                    Text(_nameController.text,
                        style: const TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildField(controller: _nameController, label: 'Full Name', icon: Icons.person, enabled: _isEditing),
                  const SizedBox(height: 14),
                  _buildField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone, enabled: _isEditing, keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),
                  _buildField(controller: _emailController, label: 'Email Address', icon: Icons.email, enabled: _isEditing, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _buildField(controller: _locationController, label: 'Location', icon: Icons.location_on, enabled: _isEditing),
                  const SizedBox(height: 14),
                  _buildField(controller: _skillsController, label: 'Skills', icon: Icons.build, enabled: _isEditing),
                  const SizedBox(height: 14),
                  _buildField(controller: _experienceController, label: 'Experience', icon: Icons.star, enabled: _isEditing),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout, color: AppColors.danger),
                      label: const Text('Log Out', style: TextStyle(color: AppColors.danger, fontSize: 16, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller, required String label, required IconData icon, required bool enabled, TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: enabled ? Border.all(color: AppColors.accent, width: 1.5) : Border.all(color: Colors.transparent),
      ),
      child: TextFormField(
        controller: controller, enabled: enabled, keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.text, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.text.withOpacity(0.6), fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'This field cannot be empty' : null,
      ),
    );
  }
}