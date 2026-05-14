import 'package:flutter/material.dart';
import 'app_colors.dart';

class PastJobsScreen extends StatefulWidget {
  const PastJobsScreen({super.key});

  @override
  State<PastJobsScreen> createState() => _PastJobsScreenState();
}

class _PastJobsScreenState extends State<PastJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _completedJobs = const [
    {"title": "Pipe Leak Repair", "provider": "John Doe", "date": "Mar 28, 2025", "price": 2800, "rating": 5, "category": "Plumbing", "icon": Icons.plumbing, "status": "Completed"},
    {"title": "Electrical Wiring Fix", "provider": "Sparky Steve", "date": "Mar 14, 2025", "price": 3500, "rating": 4, "category": "Electrical", "icon": Icons.electrical_services, "status": "Completed"},
    {"title": "Deep House Cleaning", "provider": "John Nolan", "date": "Feb 20, 2025", "price": 2000, "rating": 4, "category": "Cleaning", "icon": Icons.cleaning_services, "status": "Completed"},
    {"title": "Garden Trimming", "provider": "Mike Pipe", "date": "Jan 10, 2025", "price": 1500, "rating": 5, "category": "Gardening", "icon": Icons.grass, "status": "Completed"},
  ];

  final List<Map<String, dynamic>> _cancelledJobs = const [
    {"title": "Wall Painting", "provider": "N/A", "date": "Mar 5, 2025", "price": 0, "rating": 0, "category": "Painting", "icon": Icons.format_paint, "status": "Cancelled"},
    {"title": "Furniture Repair", "provider": "John Doe", "date": "Feb 1, 2025", "price": 0, "rating": 0, "category": "Repair", "icon": Icons.build, "status": "Cancelled"},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSummaryHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildJobList(_completedJobs),
              _buildJobList(_cancelledJobs),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    final totalSpent =
        _completedJobs.fold<int>(0, (sum, job) => sum + (job["price"] as int));
    final avgRating = _completedJobs.isEmpty
        ? 0.0
        : _completedJobs.fold<double>(0, (sum, job) => sum + (job["rating"] as int)) /
            _completedJobs.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryTile("Total Jobs", "${_completedJobs.length}", Icons.work_history),
          _divider(),
          _summaryTile("Spent", "Rs. $totalSpent", Icons.payments_outlined),
          _divider(),
          _summaryTile("Avg Rating", avgRating.toStringAsFixed(1), Icons.star_outline),
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: Colors.white10);

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
              color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          dividerColor: Colors.transparent,
          tabs: [
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.check_circle_outline, size: 16),
              const SizedBox(width: 6),
              Text("Completed (${_completedJobs.length})"),
            ])),
            Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.cancel_outlined, size: 16),
              const SizedBox(width: 6),
              Text("Cancelled (${_cancelledJobs.length})"),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _buildJobList(List<Map<String, dynamic>> jobs) {
    if (jobs.isEmpty) {
      return const Center(
          child: Text("No jobs here yet.", style: TextStyle(color: Colors.white38)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _buildJobCard(jobs[index]),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final bool isCompleted = job["status"] == "Completed";
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.secondary, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: AppColors.background, borderRadius: BorderRadius.circular(14)),
            child: Icon(job["icon"] as IconData, color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(job["title"],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(job["status"],
                          style: TextStyle(
                              color:
                                  isCompleted ? Colors.greenAccent : Colors.redAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? "by ${job["provider"]}" : "Cancelled before start",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(job["date"],
                        style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    const Spacer(),
                    if (isCompleted) ...[
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < (job["rating"] as int) ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("Rs. ${job["price"]}",
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
