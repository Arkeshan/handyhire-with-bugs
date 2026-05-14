import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'job_status_provider.dart';
import 'job_tracking_screen.dart';
import 'provider_profile_screen.dart';
import 'home_screen.dart'; // Required for navigation

class SuggestedProvidersScreen extends StatefulWidget {
  const SuggestedProvidersScreen({super.key});

  @override
  State<SuggestedProvidersScreen> createState() =>
      _SuggestedProvidersScreenState();
}

class _SuggestedProvidersScreenState extends State<SuggestedProvidersScreen> {
  final List<Map<String, dynamic>> _suggestedProviders = [
    {
      "name": "John Doe",
      "rating": 4.9,
      "mins": 8,
      "price": 30,
      "score": 98,
      "jobs": 142,
      "specialty": "Plumbing & Electrical",
    },
    {
      "name": "Sparky Steve",
      "rating": 4.8,
      "mins": 12,
      "price": 35,
      "score": 94,
      "jobs": 98,
      "specialty": "Electrical",
    },
    {
      "name": "Mike Pipe",
      "rating": 4.5,
      "mins": 18,
      "price": 22,
      "score": 87,
      "jobs": 210,
      "specialty": "Plumbing",
    },
    {
      "name": "John Nolan",
      "rating": 4.3,
      "mins": 25,
      "price": 20,
      "score": 79,
      "jobs": 64,
      "specialty": "General Repair",
    },
  ];

  String? _selectedProviderName;

  void _selectProvider(Map<String, dynamic> provider) {
    setState(() => _selectedProviderName = provider["name"]);
  }

  void _confirmSelection() {
    if (_selectedProviderName == null) return;

    JobStatusProvider.targetProvider = _selectedProviderName;
    JobStatusProvider.updateStatus("Requesting $_selectedProviderName...", 0);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        JobStatusProvider.updateStatus(
          "$_selectedProviderName accepted your request!",
          1,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JobTrackingScreen()),
        );
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            const SizedBox(height: 20),
            Text(
              "Requesting $_selectedProviderName...",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepts the Android system back-swipe or back-button
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;

        JobStatusProvider.resetStatus();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Suggested Providers",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: _suggestedProviders.length,
                itemBuilder: (context, index) =>
                    _buildProviderCard(_suggestedProviders[index], index),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: AppColors.accent, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Ranked by provider score — based on rating, jobs completed & proximity.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> provider, int index) {
    final bool isSelected = _selectedProviderName == provider["name"];
    final bool isTopPick = index == 0;

    return GestureDetector(
      onTap: () => _selectProvider(provider),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.15)
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.background,
                  child: Text(
                    provider["name"][0],
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                if (isTopPick)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "TOP",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        provider["name"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _scoreColor(
                            provider["score"],
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Score: ${provider["score"]}",
                          style: TextStyle(
                            color: _scoreColor(provider["score"]),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider["specialty"],
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _chip(Icons.star, "${provider["rating"]}", Colors.amber),
                      const SizedBox(width: 8),
                      _chip(
                        Icons.directions_walk,
                        "${provider["mins"]}m",
                        Colors.white60,
                      ),
                      const SizedBox(width: 8),
                      _chip(
                        Icons.attach_money,
                        "\$${provider["price"]}/hr",
                        AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProviderProfileScreen(provider: provider),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white38,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.accent : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.black, size: 14)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Color _scoreColor(int score) {
    if (score >= 90) return Colors.greenAccent;
    if (score >= 75) return AppColors.accent;
    return Colors.orange;
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      color: AppColors.secondary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedProviderName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "Selected: $_selectedProviderName",
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedProviderName != null
                  ? _confirmSelection
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                disabledBackgroundColor: Colors.white10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                _selectedProviderName != null
                    ? "Confirm Selection"
                    : "Select a Provider",
                style: TextStyle(
                  color: _selectedProviderName != null
                      ? Colors.black
                      : Colors.white24,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ADDED: Cancel Request Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                JobStatusProvider.resetStatus();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Cancel Request",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
