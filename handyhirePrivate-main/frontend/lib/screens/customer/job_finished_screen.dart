import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'job_status_provider.dart';
import 'home_screen.dart';

class JobFinishedScreen extends StatefulWidget {
  const JobFinishedScreen({super.key});

  @override
  State<JobFinishedScreen> createState() => _JobFinishedScreenState();
}

class _JobFinishedScreenState extends State<JobFinishedScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _completeAndGoHome() {
    JobStatusProvider.resetStatus();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppColors.accent, size: 100),
                const SizedBox(height: 24),
                const Text("Service Complete!",
                    style: TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  "How was your experience with ${JobStatusProvider.targetProvider ?? 'your provider'}?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                _buildStarRating(),
                const SizedBox(height: 30),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Leave a comment for the provider...",
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: AppColors.secondary,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _selectedRating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 45,
              ),
              onPressed: () => setState(() => _selectedRating = index + 1),
            );
          }),
        ),
        if (_selectedRating > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text("You rated this service $_selectedRating stars",
                style: const TextStyle(
                    color: AppColors.accent, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    bool isReady = _selectedRating > 0;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isReady ? _completeAndGoHome : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isReady ? AppColors.accent : Colors.white10,
          disabledBackgroundColor: Colors.white10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          isReady ? "Submit Rating" : "Please Select Stars",
          style: TextStyle(
            color: isReady ? Colors.black : Colors.white24,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
