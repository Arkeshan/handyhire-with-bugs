import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'job_request_screen.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> category;

  // REMOVED: _providerData map is gone.

  const CategoryDetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.5), // Subtle background
              shape: BoxShape.circle,
            ),
            child: IconButton(
              // Changed to standard Material back arrow
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      // UPDATED: Added SizedBox to force perfect horizontal centering
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            _buildHeader(),
            // UPDATED: Use Expanded instead of Spacers for better vertical balance
            Expanded(child: _buildEmptyState()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JobRequestScreen()),
          );
        },
        label: const Text(
          "Create Job Request",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        icon: const Icon(Icons.add, color: Colors.black),
        backgroundColor: AppColors.accent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: AppColors.secondary,
          child: Icon(category["icon"], size: 50, color: AppColors.accent),
        ),
        const SizedBox(height: 15),
        Text(
          category["name"],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        // UPDATED: Changed subtitle since we aren't showing providers anymore
        const Text(
          "Post a job to get offers",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  // REMOVED: _buildProviderCard is completely gone.

  // UPDATED: Empty state now reflects requests, not providers.
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.assignment_outlined, size: 80, color: Colors.white24),
        const SizedBox(height: 16),
        Text(
          "No active requests for ${category['name']}.",
          style: const TextStyle(color: Colors.white54, fontSize: 16),
          textAlign: TextAlign.center, // Ensures text is centered if it wraps
        ),
        // ADDED: This invisible box pushes the icon/text up slightly
        // so it doesn't get hidden behind the Floating Action Button!
        const SizedBox(height: 80),
      ],
    );
  }
}
