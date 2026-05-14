import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'job_request_detail_screen.dart';


class NegotiationsScreen extends StatefulWidget {
  const NegotiationsScreen({super.key});

  @override
  State<NegotiationsScreen> createState() => _NegotiationsScreenState();
}

class _NegotiationsScreenState extends State<NegotiationsScreen> {
  List<Map<String, String>> jobRequests = [
    {'customerName': 'John Doe', 'title': 'Plumbing Repair', 'price': 'Rs. 2,500', 'description': 'Fix leaking pipes under the kitchen sink.', 'location': '123 Main St, Colombo 03', 'image': 'plumbing'},
    {'customerName': 'Sarah Williams', 'title': 'Electrical Wiring', 'price': 'Rs. 4,000', 'description': 'Install new electrical outlets in the living room.', 'location': '45 Park Road, Kandy', 'image': 'electrical'},
    {'customerName': 'Michael Brown', 'title': 'AC Installation', 'price': 'Rs. 8,500', 'description': 'Install a new 1.5 ton inverter AC unit.', 'location': '78 Lake View, Nugegoda', 'image': 'ac'},
    {'customerName': 'Emily Davis', 'title': 'Painting Work', 'price': 'Rs. 3,200', 'description': 'Paint two rooms including ceiling.', 'location': '22 Hill Street, Gampaha', 'image': 'painting'},
  ];

  void _removeJob(int index) {
    setState(() => jobRequests.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Job Requests',
            style: TextStyle(
                color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: jobRequests.isEmpty
          ? const Center(
              child: Text('No job requests available',
                  style: TextStyle(color: AppColors.text, fontSize: 18)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: jobRequests.length,
              itemBuilder: (context, index) {
                final job = jobRequests[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              JobRequestDetailScreen(job: job, jobIndex: index),
                        ),
                      );
                      if (result != null && result['action'] == 'remove') {
                        _removeJob(result['index']);
                      }
                    },
                    child: _buildJobCard(job),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildJobCard(Map<String, String> job) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job['customerName']!,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(job['title']!,
                    style: TextStyle(
                        color: AppColors.text.withOpacity(0.8), fontSize: 16)),
                const SizedBox(height: 8),
                Text(job['price']!,
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 20),
        ],
      ),
    );
  }
}
