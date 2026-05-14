import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../../services/session_service.dart';
import 'app_colors.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _isEditing = false;

  // Start with empty controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load the real user data from SessionService
  void _loadUserData() {
    final session = SessionService.instance;
    setState(() {
      _nameController.text = session.displayName ?? "Unknown User";
      _emailController.text = session.email ?? "No email provided";
      _phoneController.text = session.phone ?? "No phone provided";
      _addressController.text =
          "Add your address..."; // Address isn't in DB yet
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // TODO: Later, call ApiService to save updated details to the backend
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _handleLogout() async {
    await SessionService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          _buildStatsRow(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _toggleEdit,
                      icon: Icon(
                        _isEditing ? Icons.check : Icons.edit_outlined,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      label: Text(
                        _isEditing ? "Save" : "Edit",
                        style: const TextStyle(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoField(
                  Icons.person_outline,
                  "Full Name",
                  _nameController,
                ),
                _buildInfoField(
                  Icons.email_outlined,
                  "Email",
                  _emailController,
                ),
                _buildInfoField(
                  Icons.phone_outlined,
                  "Phone",
                  _phoneController,
                ),
                _buildInfoField(
                  Icons.location_on_outlined,
                  "Address",
                  _addressController,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person, size: 70, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("0", "Jobs Done"),
          _verticalDivider(),
          _statItem("N/A", "Avg Given"),
          _verticalDivider(),
          _statItem("Rs. 0", "Total Spent"),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _verticalDivider() =>
      Container(width: 1, height: 36, color: Colors.white10);

  Widget _buildInfoField(
    IconData icon,
    String label,
    TextEditingController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: _isEditing,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
