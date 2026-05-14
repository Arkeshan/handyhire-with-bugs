import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OngoingJobsScreen extends StatefulWidget {
  const OngoingJobsScreen({super.key});

  @override
  State<OngoingJobsScreen> createState() => _OngoingJobsScreenState();
}

class _OngoingJobsScreenState extends State<OngoingJobsScreen> {
  // TODO(team): replace _mockJobs with ApiService.instance.getOpenJobs() etc.
  final List<Map<String, dynamic>> _mockJobs = [
    {
      'id': 'TRK-9021A',
      'title': 'Plumbing Repair',
      'provider': 'Kamal Perera',
      'time': '10:30 AM - Today',
      'status': 'On the way'
    },
    {
      'id': 'TRK-4412B',
      'title': 'A/C Servicing',
      'provider': 'Nuwan Silva',
      'time': '11:00 AM - Today',
      'status': 'Reached'
    },
    {
      'id': 'TRK-8839C',
      'title': 'Electrical Wiring',
      'provider': 'Suresh Dinesh',
      'time': '01:15 PM - Today',
      'status': 'In Progress'
    },
  ];

  void _terminateJob(String jobId) {
    setState(() => _mockJobs.removeWhere((job) => job['id'] == jobId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job $jobId has been terminated.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showTerminateConfirmation(String jobId, String jobTitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E355B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            Text('Terminate Job?', style: GoogleFonts.poppins(color: Colors.white)),
          ],
        ),
        content: Text(
          'Are you sure you want to forcibly terminate "$jobTitle" (ID: $jobId)? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8EBBFF)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _terminateJob(jobId);
            },
            child: const Text('Yes, Terminate',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Ongoing Jobs',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: const Color(0xFFB18E44))),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _mockJobs.isEmpty
            ? const Center(
                child: Text('No ongoing jobs at the moment.',
                    style: TextStyle(color: Colors.white70, fontSize: 18)))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _mockJobs.length,
                itemBuilder: (context, index) {
                  final job = _mockJobs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E355B),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFC0C0C2).withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job['title'],
                                  style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              const SizedBox(height: 5),
                              Text('ID: ${job['id']} • ${job['status']}',
                                  style: const TextStyle(
                                      color: Color(0xFFB18E44),
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 5),
                              Text(
                                'Provider: ${job['provider']}\nTime: ${job['time']}',
                                style: const TextStyle(color: Colors.white70, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.cancel_outlined,
                                color: Colors.redAccent, size: 30),
                            onPressed: () =>
                                _showTerminateConfirmation(job['id'], job['title']),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
