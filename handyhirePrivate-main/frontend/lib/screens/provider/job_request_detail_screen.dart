import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class JobRequestDetailScreen extends StatelessWidget {
  final dynamic job; // Changed to dynamic to handle backend Map
  final int jobIndex;

  const JobRequestDetailScreen({super.key, required this.job, required this.jobIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Job Details', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(job['title'] ?? 'Title', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildDetailBox("Customer", job['customerName'] ?? "Unknown"),
            _buildDetailBox("Budget", "Rs. ${job['budget']}"),
            _buildDetailBox("Location", job['location'] ?? "Sri Lanka"),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, minimumSize: const Size(double.infinity, 50)),
              onPressed: () { /* Accept Logic */ },
              child: const Text("Accept Job"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(10)),
      child: Text("$label: $value", style: const TextStyle(color: Colors.white70)),
    );
  }
}