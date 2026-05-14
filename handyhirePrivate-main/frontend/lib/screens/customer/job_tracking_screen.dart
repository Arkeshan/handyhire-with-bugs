import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'job_status_provider.dart';
import 'chat_screen.dart';

class JobTrackingScreen extends StatefulWidget {
  const JobTrackingScreen({super.key});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  @override
  void initState() {
    super.initState();
    JobStatusProvider.stepNotifier.addListener(_refreshUI);
  }

  @override
  void dispose() {
    JobStatusProvider.stepNotifier.removeListener(_refreshUI);
    super.dispose();
  }

  void _refreshUI() {
    if (mounted) setState(() {});
  }

  void _showCounterDialog() {
    final TextEditingController counterController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Counter Offer", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: counterController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Your Price",
            hintStyle: const TextStyle(color: Colors.white24),
            prefixText: "Rs. ",
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () {
              setState(() {
                JobStatusProvider.currentPrice =
                    double.tryParse(counterController.text) ?? JobStatusProvider.currentPrice;
                JobStatusProvider.isNegotiating = false;
                JobStatusProvider.isPaused = true;
                JobStatusProvider.updateStatus(
                    "Counter-offer sent...", JobStatusProvider.currentStep);
              });
              Navigator.pop(context);
            },
            child: const Text("Send", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.redAccent,
        label: const Text("Simulate Provider Offer"),
        icon: const Icon(Icons.bug_report),
        onPressed: () {
          setState(() {
            JobStatusProvider.isNegotiating = true;
            JobStatusProvider.isPaused = true;
            JobStatusProvider.currentPrice = 5500.0;
            JobStatusProvider.providerMessage =
                "I need more for the extra materials.";
            JobStatusProvider.updateStatus(
                "Provider sent a counter-offer!", JobStatusProvider.currentStep);
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Injected Provider Negotiation State")));
        },
      ),
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Job Tracking",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.accent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1E2E45),
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.accent)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Text(JobStatusProvider.statusMessage,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  if (JobStatusProvider.isNegotiating) _buildNegotiationCard(),
                  const SizedBox(height: 25),
                  _buildMainProviderCard(),
                  const SizedBox(height: 30),
                  _buildTimeline(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      color: AppColors.accent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepIcon(Icons.check_circle, "Confirmed", JobStatusProvider.currentStep >= 1),
          _stepLine(JobStatusProvider.currentStep >= 2),
          _stepIcon(Icons.directions_walk, "On Way", JobStatusProvider.currentStep >= 2),
          _stepLine(JobStatusProvider.currentStep >= 3),
          _stepIcon(Icons.home, "Arrived", JobStatusProvider.currentStep >= 3),
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(icon, color: isActive ? Colors.black : Colors.black26, size: 28),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: isActive ? Colors.black : Colors.black26,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? Colors.black : Colors.black12,
      ),
    );
  }

  Widget _buildMainProviderCard() {
    bool hasFound = JobStatusProvider.currentStep >= 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: AppColors.secondary, borderRadius: BorderRadius.circular(30)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.background,
            child: Icon(hasFound ? Icons.person : Icons.search,
                size: 60, color: AppColors.accent),
          ),
          const SizedBox(height: 20),
          Text(
            hasFound
                ? (JobStatusProvider.targetProvider ?? "Provider")
                : "Searching...",
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text("Professional Provider",
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          if (hasFound) ...[
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionBtn(Icons.call, "Call"),
                const SizedBox(width: 30),
                _actionBtn(Icons.chat_bubble, "Chat"),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "Chat") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                  providerName: JobStatusProvider.targetProvider ?? "Provider"),
            ),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
              backgroundColor: AppColors.background,
              child: Icon(icon, color: AppColors.accent, size: 20)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildNegotiationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Text("Price Proposal",
              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Rs. ${JobStatusProvider.currentPrice.toStringAsFixed(0)}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: () => setState(() {
                  JobStatusProvider.isNegotiating = false;
                  JobStatusProvider.isPaused = false;
                  JobStatusProvider.updateStatus(
                      "Price Agreed!", JobStatusProvider.currentStep);
                }),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Accept"),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: OutlinedButton(
                onPressed: _showCounterDialog,
                style:
                    OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.accent)),
                child: const Text("Counter", style: TextStyle(color: AppColors.accent)),
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: [
        _timelineStep("Accepted & Confirmed", JobStatusProvider.currentStep >= 1),
        _timelineStep("Provider on the way", JobStatusProvider.currentStep >= 2),
        _timelineStep("Job in Progress", JobStatusProvider.currentStep >= 3),
      ],
    );
  }

  Widget _timelineStep(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? Colors.green : Colors.white10),
          const SizedBox(width: 15),
          Text(title,
              style: TextStyle(
                  color: isDone ? Colors.white : Colors.white10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
