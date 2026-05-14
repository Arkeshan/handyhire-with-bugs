import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'upload_proof_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Active Job',
            style: TextStyle(
                color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadProofScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.text,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Complete Job',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Ongoing Job',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Text('Plumbing Repair',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  _infoRow(Icons.person, 'Customer: John Doe'),
                  const SizedBox(height: 10),
                  _infoRow(Icons.location_on, 'Location: 123 Main St'),
                  const SizedBox(height: 10),
                  _infoRow(Icons.attach_money, 'Rs. 2,500', color: AppColors.accent),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Pending Jobs',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPendingCard('Electrical Wiring', 'Sarah Williams', 'Rs. 4,000'),
            const SizedBox(height: 12),
            _buildPendingCard('AC Installation', 'Michael Brown', 'Rs. 8,500'),
            const SizedBox(height: 12),
            _buildPendingCard('Painting Work', 'Emily Davis', 'Rs. 3,200'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color ?? AppColors.text.withOpacity(0.7), size: 18),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                color: color ?? AppColors.text.withOpacity(0.9), fontSize: 15)),
      ],
    );
  }

  Widget _buildPendingCard(String title, String customer, String price) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Customer: $customer',
              style:
                  TextStyle(color: AppColors.text.withOpacity(0.7), fontSize: 14)),
          const SizedBox(height: 6),
          Text(price,
              style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
