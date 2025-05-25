import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  double _getCompletionRate(Map<String, dynamic>? data) {
    try {
      if (data == null) return 0.0;

      final stats = data['stats'];
      if (stats == null) return 0.0;

      final taskCompletion = stats['task_completion'];
      if (taskCompletion == null) return 0.0;

      final rate = taskCompletion['completion_rate'];
      if (rate == null) return 0.0;

      // Handle both double and String cases
      if (rate is double) {
        return rate / 100.0;
      } else if (rate is String) {
        final doubleValue = double.tryParse(rate);
        return doubleValue != null ? doubleValue / 100.0 : 0.0;
      } else if (rate is int) {
        return rate / 100.0;
      }

      return 0.0;
    } catch (e) {
      print('Error in _getCompletionRate: $e');
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
    });
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
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

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color? color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color?.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color?.withAlpha(51) ?? Colors.grey.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color?.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityItem(Map<String, dynamic> activity) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
        child: Icon(
          Icons.task_alt,
          color: Theme.of(context).primaryColor,
          size: 18,
        ),
      ),
      title: Text(
        activity['task_title'] ?? 'Unknown Task',
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'Completed by ${activity['student_name']}',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        activity['completed_at'] ?? '',
        style: TextStyle(color: Colors.grey[500], fontSize: 11),
      ),
    );
  }

  Widget _buildStudentPerformanceItem(Map<String, dynamic> student) {
    double completionRate = 0.0;
    try {
      final rate = student['completion_rate'];
      if (rate is double) {
        completionRate = rate;
      } else if (rate is String) {
        completionRate = double.tryParse(rate) ?? 0.0;
      } else if (rate is int) {
        completionRate = rate.toDouble();
      }
    } catch (e) {
      print('Error parsing student completion rate: $e');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                child: Text(
                  student['name']?[0] ?? '?',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student['name'] ?? 'Unknown Student',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      student['registration_number'] ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tasks Completed',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${student['completed_tasks']}/${student['total_tasks']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      completionRate >= 80
                          ? Colors.green.withAlpha(26)
                          : completionRate >= 50
                          ? Colors.orange.withAlpha(26)
                          : Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${completionRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color:
                        completionRate >= 80
                            ? Colors.green
                            : completionRate >= 50
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchDashboardData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (auth.dashboardData != null &&
                          auth.dashboardData!['success'] == true) ...[
                        // Overview Statistics
                        Text(
                          'Overview',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.3,
                          children: [
                            _buildStatItem(
                              'Total Students',
                              auth.dashboardData!['stats']?['total_students']
                                      ?.toString() ??
                                  '0',
                              Icons.people,
                              Colors.blue,
                            ),
                            _buildStatItem(
                              'Total Tasks',
                              auth.dashboardData!['stats']?['total_tasks']
                                      ?.toString() ??
                                  '0',
                              Icons.task,
                              Colors.orange,
                            ),
                            _buildStatItem(
                              'Completed Tasks',
                              auth.dashboardData!['stats']?['task_completion']?['total_completed']
                                      ?.toString() ??
                                  '0',
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildStatItem(
                              'Pending Tasks',
                              auth.dashboardData!['stats']?['task_completion']?['total_pending']
                                      ?.toString() ??
                                  '0',
                              Icons.pending,
                              Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Task Completion Rate
                        Text(
                          'Task Completion Rate',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withAlpha(51),
                            ),
                          ),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: _getCompletionRate(auth.dashboardData),
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_getCompletionRate(auth.dashboardData) * 100}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Recent Activities
                        Text(
                          'Recent Activities',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withAlpha(51),
                            ),
                          ),
                          child: Column(
                            children: [
                              ...(auth.dashboardData!['stats']?['recent_activities']?['recent_completions']
                                          as List<dynamic>? ??
                                      [])
                                  .map(
                                    (activity) => Column(
                                      children: [
                                        _buildRecentActivityItem(activity),
                                        const Divider(height: 24),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Student Performance
                        Text(
                          'Top Performing Students',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...(auth.dashboardData!['stats']?['student_performance']
                                    as List<dynamic>? ??
                                [])
                            .map(
                              (student) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildStudentPerformanceItem(student),
                              ),
                            )
                            .toList(),
                      ] else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No dashboard data available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchDashboardData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}
