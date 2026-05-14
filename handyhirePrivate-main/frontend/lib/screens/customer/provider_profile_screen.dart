import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'job_request_screen.dart';
import 'chat_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderProfileScreen({super.key, required this.provider});

  void _showJobDetails(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text("Project Showcase",
                  style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 200,
                  color: Colors.white10,
                  child: Center(
                    child: Icon(Icons.image,
                        size: 80, color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text("Typical Project Description",
                  style:
                      TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                "Complete installation of modern fixtures and leak prevention system. This project was completed within the estimated timeframe and budget.",
                style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildSmallInfo(Icons.payments_outlined, "Cost: \$120"),
                  const SizedBox(width: 20),
                  _buildSmallInfo(Icons.timer_outlined, "Duration: 3h"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(Icons.access_time, "${provider["mins"]}m away"),
                      _buildStatCard(Icons.monetization_on_outlined,
                          "\$${provider["price"]}/h"),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _sectionTitle("About Me"),
                  const Text(
                    "Professional service provider with a passion for excellence. I specialize in high-quality repairs and maintenance with a 100% satisfaction guarantee.",
                    style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  _sectionTitle("Recent Work"),
                  const SizedBox(height: 12),
                  _buildPastWorkGallery(context),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobRequestScreen(selectedProvider: provider),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      minimumSize: const Size(double.infinity, 55),
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Book Appointment",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(providerName: provider["name"]),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      side: const BorderSide(color: Colors.white24),
                      shape:
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Contact Message",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person, size: 70, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Text(provider["name"],
              style: const TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text("${provider["rating"]} (85 Reviews)",
                  style: const TextStyle(color: Colors.white60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastWorkGallery(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => InkWell(
          onTap: () => _showJobDetails(context, index),
          child: Container(
            width: 130,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
                child: Icon(Icons.image, size: 40, color: Colors.white24)),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.secondary, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
