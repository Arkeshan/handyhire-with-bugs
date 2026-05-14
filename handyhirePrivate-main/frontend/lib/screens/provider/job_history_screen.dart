import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';

class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({super.key});

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
  List<dynamic> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      // Use SharedPreferences directly since SessionService is missing the method
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final response = await ApiService.instance.getJobHistory(userId);
        setState(() {
          _history = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
        title: const Text('Job History',
            style: TextStyle(color: AppColors.text, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _history.isEmpty
              ? const Center(child: Text('No completed jobs yet', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _history.length,
                  itemBuilder: (context, index) => _buildHistoryCard(_history[index]),
                ),
    );
  }

  Widget _buildHistoryCard(dynamic job) {
    return Card(
      color: AppColors.secondary,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(Icons.check_circle, color: AppColors.success),
        title: Text(job['title'] ?? 'Job', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(job['date'] ?? 'Recently', style: const TextStyle(color: Colors.white70)),
        trailing: Text("Rs. ${job['price']}", style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
      ),
    );
  }
}