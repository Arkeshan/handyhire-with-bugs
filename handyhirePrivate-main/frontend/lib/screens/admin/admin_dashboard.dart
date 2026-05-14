import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ongoing_jobs_screen.dart';
import 'disputes_screen.dart';
import 'provider_verification_screen.dart';
import '../../services/session_service.dart'; // ADDED
import '../auth/login_screen.dart'; // ADDED

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // ADDED: Logout logic
  Future<void> _handleLogout(BuildContext context) async {
    await SessionService.instance.logout();
    
    if (!context.mounted) return;
    
    // Navigate back to Login and completely clear the history stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Admin Control',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFB18E44),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        // ADDED: Logout button in the top right corner
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _buildDashboardTile(
                context,
                title: 'Ongoing\nJobs',
                icon: Icons.work_history,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OngoingJobsScreen()),
                ),
              ),
              _buildDashboardTile(
                context,
                title: 'Disputes',
                icon: Icons.warning_amber_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DisputesScreen()),
                ),
              ),
              _buildDashboardTile(
                context,
                title: 'User\nVerification', // UPDATED TITLE
                icon: Icons.verified_user,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProviderVerificationScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E355B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8EBBFF), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFFB18E44)),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}