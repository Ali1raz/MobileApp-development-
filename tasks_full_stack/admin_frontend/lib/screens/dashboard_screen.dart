import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/dashboard_excel_export.dart';
import '../services/excel_service.dart';
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

  Future<void> _exportToExcel() async {
    try {
      if (!await ExcelService.requestStoragePermission(context)) return;

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final dashboardData = auth.dashboardData;

      if (dashboardData == null || dashboardData['success'] != true) {
        throw Exception('Invalid dashboard data');
      }

      // Create Excel workbook
      final excelDoc = DashboardExcelExport.createDashboardExcel(dashboardData);

      // Save the Excel file
      final dateStamp = DateTime.now()
          .toString()
          .replaceAll(':', '-')
          .replaceAll(' ', '_');
      final fileName = 'dashboard_stats_$dateStamp.xlsx';

      final filePath = await ExcelService.getExcelFilePath(fileName);
      if (filePath == null) {
        throw Exception('Could not determine file save location');
      }

      final success = await ExcelService.saveExcelFile(excelDoc, filePath);
      if (!success) {
        throw Exception('Failed to save Excel file');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Excel file exported successfully!'),
                Text(
                  'Saved to: ${filePath.split('/').last}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to Excel: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
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
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (!_isLoading && auth.dashboardData != null)
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Export to Excel',
              onPressed: _exportToExcel,
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDashboardContent(context, auth),
    );
  }
}
