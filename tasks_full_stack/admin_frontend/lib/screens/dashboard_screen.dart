import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/dashboard/stats_grid.dart';
import '../widgets/dashboard/recent_activities.dart';
import '../widgets/dashboard/student_performance_card.dart';
import '../widgets/dashboard/completion_progress.dart';
import '../widgets/common/section_header.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.fetchDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchDashboardData,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDashboardContent(BuildContext context, AuthProvider auth) {
    if (auth.dashboardData == null || auth.dashboardData!['success'] != true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No dashboard data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = auth.dashboardData!['stats'];
    final recentActivities =
        (stats['recent_activities']['recent_completions'] as List<dynamic>?) ??
        [];
    final studentPerformance =
        (stats['student_performance'] as List<dynamic>?) ?? [];

    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Overview'),
            StatsGrid(stats: stats),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Task Completion Rate'),
            CompletionProgress(taskCompletion: stats['task_completion']),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Recent Activities'),
            RecentActivitiesList(activities: recentActivities),
            const SizedBox(height: 24),

            const SectionHeader(title: 'Top Performing Students'),
            ...studentPerformance.map(
              (student) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StudentPerformanceCard(student: student),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDashboardContent(context, auth),
    );
  }
}
