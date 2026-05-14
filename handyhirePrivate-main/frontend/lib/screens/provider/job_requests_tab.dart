import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import 'job_request_detail_screen.dart';

class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBroadcastedJobs();
  }

  Future<void> _fetchBroadcastedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? "";

      // 1. Get the real skill from the profile
      final profile = await ApiService.instance.getProfile(email);
      final mySkill = profile['skills'] ?? "General";

      // 2. Fetch jobs for that skill
      final response = await ApiService.instance.getOpenJobs(category: mySkill);
      
      setState(() {
        _jobs = response['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    
    return RefreshIndicator(
      onRefresh: _fetchBroadcastedJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return JobCard(
            title: job['title'] ?? 'Task',
            customer: job['customerName'] ?? 'Unknown',
            price: "Rs. ${job['budget'] ?? '0'}",
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => JobRequestDetailScreen(job: job, jobIndex: index)
            )),
          );
        },
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String customer;
  final String price;
  final VoidCallback onTap;

  const JobCard({super.key, required this.title, required this.customer, required this.price, required this.onTap});

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 1. ADDED THE HEADER BACK
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Job Requests',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _jobs.isEmpty
              // 2. ADDED THE "NO REQUESTS" MESSAGE
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_late_outlined, 
                        size: 60, 
                        color: AppColors.text.withOpacity(0.2)
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No new requests in your category.',
                        style: TextStyle(
                          color: AppColors.text.withOpacity(0.5), 
                          fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _fetchBroadcastedJobs,
                        child: const Text("Tap to Refresh", style: TextStyle(color: AppColors.accent)),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchBroadcastedJobs,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      final job = _jobs[index];
                      return JobCard(
                        title: job['title'] ?? 'Task',
                        customer: job['customerName'] ?? 'Unknown',
                        price: "Rs. ${job['budget'] ?? '0'}",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobRequestDetailScreen(job: job, jobIndex: index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}