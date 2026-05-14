import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../../services/api_service.dart';
import 'job_request_detail_screen.dart';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;
  
  // NEW: Store the skill at the class level so the WebSocket can use it
  String _mySkill = "General"; 
  
  // NEW: This is the "phone" that will stay connected to the server
  StompClient? stompClient; 

  @override
  void initState() {
    super.initState();
    // NEW: We change this to a setup function to do things in order
    _initializeScreen(); 
  }

  // NEW: Setup function
  Future<void> _initializeScreen() async {
    await _fetchBroadcastedJobs(); // 1. Get existing jobs from database
    _connectWebSocket();           // 2. Start listening for brand new jobs
  }

  // NEW: The WebSocket connection logic
  void _connectWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        // IMPORTANT IP ADDRESS NOTE:
        // If using an Android Emulator, use '10.0.2.2' instead of 'localhost'
        // If using a physical phone, use your computer's actual WiFi IP (e.g., 192.168.1.5)
        url: 'ws://10.0.2.2:8080/ws-handyhire/websocket', 
        onConnect: onWebSocketConnected,
        onWebSocketError: (dynamic error) => print("WebSocket Error: $error"),
      ),
    );
    stompClient!.activate(); // "Picks up the phone"
  }

  // NEW: What to do when the phone connects
  void onWebSocketConnected(StompFrame frame) {
    print("Connected to live jobs! Listening for: $_mySkill");
    
    // "Tune in" to the specific radio station for this provider's skill
    stompClient!.subscribe(
      destination: '/topic/jobs/$_mySkill',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          // A new job arrived! Decode it from text to a Dart Map
          final newJob = json.decode(frame.body!);
          
          if (mounted) {
            setState(() {
              // Add the new job to the VERY TOP of the list (index 0)
              _jobs.insert(0, newJob);
            });
          }
        }
      },
    );
  }

  // NEW: ALWAYS hang up the phone when the user leaves this screen!
  @override
  void dispose() {
    stompClient?.deactivate(); 
    super.dispose();
  }

  Future<void> _fetchBroadcastedJobs() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? "";

      final profile = await ApiService.instance.getProfile(email);
      // NEW: Update the class-level variable here
      _mySkill = profile['profession'] ?? profile['skills'] ?? "General";

      final response = await ApiService.instance.getOpenJobs(category: _mySkill);

      setState(() {
        final raw = response['data'] ?? response;
        _jobs = raw is List ? raw : [];
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching jobs: $e");
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _jobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_late_outlined,
                        size: 60,
                        color: AppColors.text.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No new requests in your category.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _fetchBroadcastedJobs,
                        child: const Text(
                          "Tap to Refresh",
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchBroadcastedJobs,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _jobs.length,
                    itemBuilder: (context, index) {
                      final job = _jobs[index];
                      return JobCard(
                        title: job['title'] ?? 'Task',
                        customer:
                            job['customerName'] ?? job['userName'] ?? 'Unknown',
                        price: "Rs. ${job['budget'] ?? job['price'] ?? '0'}",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobRequestDetailScreen(
                              job: job,
                              jobIndex: index,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ── Reusable JobCard widget ───────────────────────────────────────────────────

class JobCard extends StatelessWidget {
  final String title;
  final String customer;
  final String price;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.title,
    required this.customer,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E355B),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Customer: $customer",
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFFB18E44),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.accent,
              size: 14,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}