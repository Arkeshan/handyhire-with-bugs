import 'dart:async';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'job_status_provider.dart';
import 'job_tracking_screen.dart';
import 'suggested_providers_screen.dart';

class FindingProviderScreen extends StatefulWidget {
  const FindingProviderScreen({super.key});

  @override
  State<FindingProviderScreen> createState() => _FindingProviderScreenState();
}

class _FindingProviderScreenState extends State<FindingProviderScreen> {
  Timer? _refreshTimer;
  Timer? _timeoutTimer;
  Timer? _simulationTimer;

  bool get _isDirectBooking => JobStatusProvider.targetProvider != null;

  @override
  void initState() {
    super.initState();

    if (_isDirectBooking) {
      _simulationTimer = Timer(const Duration(seconds: 4), () {
        if (mounted && JobStatusProvider.currentStep == 0) {
          JobStatusProvider.updateStatus(
              "${JobStatusProvider.targetProvider} accepted your request!", 1);
        }
      });

      _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (JobStatusProvider.currentStep > 0) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const JobTrackingScreen()),
          );
        } else {
          setState(() {});
        }
      });
    } else {
      _simulationTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SuggestedProvidersScreen()),
          );
        }
      });
      _refreshTimer =
          Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    }

    if (_isDirectBooking) {
      _timeoutTimer = Timer(const Duration(seconds: 60), () {
        if (mounted &&
            JobStatusProvider.isSearching &&
            JobStatusProvider.currentStep == 0) {
          _showTimeoutDialog();
        }
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _timeoutTimer?.cancel();
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _cancelSearch() {
    JobStatusProvider.resetStatus();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _cancelSearch,
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildRadarIcon(),
            const SizedBox(height: 40),
            Text(JobStatusProvider.statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              _isDirectBooking
                  ? "Waiting for ${JobStatusProvider.targetProvider} to accept..."
                  : "Finding top-rated providers in your area...",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 80),
            TextButton(
              onPressed: _cancelSearch,
              style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              child: const Text("Cancel Request",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.accent.withOpacity(0.5)),
          ),
        ),
        const CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.secondary,
          child: Icon(Icons.search, size: 40, color: AppColors.accent),
        ),
      ],
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Still searching...", style: TextStyle(color: Colors.white)),
        content: const Text(
            "The provider hasn't responded yet. Stay or get notified later?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSearch();
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () {
              JobStatusProvider.updateStatus("Waiting for provider...", 0);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Notify Me", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
