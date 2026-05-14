import 'dart:async';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'category_details_screen.dart';
import 'job_status_provider.dart';
import 'finding_provider_screen.dart';
import 'job_finished_screen.dart';
import 'job_tracking_screen.dart';
import 'past_jobs_screen.dart';
import 'customer_profile_screen.dart';
import '../../services/session_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isTimerRunning = false;
  final List<Timer> _activeTimers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (JobStatusProvider.isSearching && !_isTimerRunning) {
      _startDemoSequence();
    }
  }

  @override
  void dispose() {
    _cancelAllTimers();
    super.dispose();
  }

  void _cancelAllTimers() {
    for (var timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
    _isTimerRunning = false;
  }

  void _startDemoSequence() {
    _cancelAllTimers();
    _isTimerRunning = true;

    Timer(const Duration(milliseconds: 200), () {
      final stages = [
        {'delay': 10, 'step': 1},
        {'delay': 20, 'step': 2},
        {'delay': 30, 'step': 3},
        {'delay': 40, 'step': 4},
      ];

      for (var stage in stages) {
        Timer t = Timer(Duration(seconds: stage['delay'] as int), () {
          if (JobStatusProvider.isSearching &&
              !JobStatusProvider.isPaused &&
              mounted) {
            _processStep(stage['step'] as int);
          } else if (JobStatusProvider.isPaused) {
            _waitForResume(stage['step'] as int);
          }
        });
        _activeTimers.add(t);
      }
    });
  }

  void _processStep(int step) {
    setState(() {
      String name = JobStatusProvider.targetProvider ?? "John Doe";
      String msg;
      if (step == 1) {
        msg = "$name accepted!";
      } else if (step == 2) {
        msg = "$name is on the way!";
      } else if (step == 3) {
        msg = "$name has arrived!";
      } else {
        msg = "Job Finished!";
      }
      JobStatusProvider.updateStatus(msg, step);

      if (step == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JobFinishedScreen()),
        ).then((_) => _handleReturn());
      }
    });
  }

  void _waitForResume(int pendingStep) {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!JobStatusProvider.isPaused) {
        if (JobStatusProvider.isSearching && mounted) {
          _processStep(pendingStep);
        }
        timer.cancel();
      }
      if (!JobStatusProvider.isSearching) timer.cancel();
    });
  }

  void _handleReturn() {
    setState(() {
      if (!JobStatusProvider.isSearching) _cancelAllTimers();
    });
  }

  Widget _buildActiveJobBar() {
    if (!JobStatusProvider.isSearching || JobStatusProvider.currentStep >= 4) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Widget destination = JobStatusProvider.currentStep == 0
            ? const FindingProviderScreen()
            : const JobTrackingScreen();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        ).then((_) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                JobStatusProvider.statusMessage,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> categories = [
    {"name": "Plumbing", "icon": Icons.plumbing},
    {"name": "Electrical", "icon": Icons.electrical_services},
    {"name": "Cleaning", "icon": Icons.cleaning_services},
    {"name": "Repair", "icon": Icons.build},
    {"name": "Gardening", "icon": Icons.grass},
    {"name": "Painting", "icon": Icons.format_paint},
  ];

  Widget _buildCategoryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Material(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CategoryDetailsScreen(category: categories[index]),
                ),
              ).then((_) => _handleReturn());
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  categories[index]["icon"],
                  color: AppColors.accent,
                  size: 32,
                ),
                const SizedBox(height: 10),
                Text(
                  categories[index]["name"],
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UPDATED: Removed 'const' from Text, added dynamic session name
          Text(
            "Hello, ${SessionService.instance.displayName ?? 'Customer'}!",
            style: const TextStyle(
              // Note: 'const' is moved here to the style!
              color: AppColors.text,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "What can I do for you today?",
            style: TextStyle(color: AppColors.text, fontSize: 16),
          ),
          const SizedBox(height: 30),
          // Your grid is back!
          Expanded(child: _buildCategoryGrid()),
        ],
      ),
    );
  }

  static const List<String> _titles = ["", "My Jobs", "My Profile"];

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold in PopScope
    return PopScope(
      // Only allow the app to close if we are already on the Home tab (index 0)
      canPop: _selectedIndex == 0,
      onPopInvoked: (bool didPop) {
        if (didPop) return;

        // If they swipe back on Profile or My Jobs, just switch the tab to Home!
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _selectedIndex == 0
            ? null
            : AppBar(
                backgroundColor: AppColors.secondary,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  _titles[_selectedIndex],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
        body: SafeArea(
          child: Column(
            children: [
              if (_selectedIndex == 0) _buildActiveJobBar(),
              Expanded(
                child: _selectedIndex == 0
                    ? _buildHomeTab()
                    : _selectedIndex == 1
                    ? const PastJobsScreen()
                    : const CustomerProfileScreen(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.secondary,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_history),
              label: "My Jobs",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
