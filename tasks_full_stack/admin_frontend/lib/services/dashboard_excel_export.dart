import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';

/// Service to handle dashboard data export to Excel
class DashboardExcelExport {
  /// Create an Excel workbook from dashboard data
  static excel.Excel createDashboardExcel(Map<String, dynamic> dashboardData) {
    final excelDoc = excel.Excel.createExcel();
    _addOverviewSheet(excelDoc, dashboardData);
    _addStudentPerformanceSheet(excelDoc, dashboardData);
    _addRecentActivitiesSheet(excelDoc, dashboardData);
    return excelDoc;
  }

  /// Add overview statistics sheet
  static void _addOverviewSheet(
    excel.Excel excelDoc,
    Map<String, dynamic> dashboardData,
  ) {
    final overviewSheet = excelDoc['Overview'];
    final stats = dashboardData['stats'];

    // Add title and timestamp
    overviewSheet.appendRow([
      excel.TextCellValue('Dashboard Statistics Overview'),
    ]);
    overviewSheet.appendRow([
      excel.TextCellValue('Generated on'),
      excel.TextCellValue(DateTime.now().toString()),
    ]);
    overviewSheet.appendRow([]);

    // Add statistics
    overviewSheet.appendRow([
      excel.TextCellValue('Total Students'),
      excel.TextCellValue(stats['total_students'].toString()),
    ]);
    overviewSheet.appendRow([
      excel.TextCellValue('Total Tasks'),
      excel.TextCellValue(stats['total_tasks'].toString()),
    ]);
    overviewSheet.appendRow([
      excel.TextCellValue('Completed Tasks'),
      excel.TextCellValue(
        stats['task_completion']['total_completed'].toString(),
      ),
    ]);
    overviewSheet.appendRow([
      excel.TextCellValue('Pending Tasks'),
      excel.TextCellValue(stats['task_completion']['total_pending'].toString()),
    ]);
    overviewSheet.appendRow([
      excel.TextCellValue('Overall Completion Rate'),
      excel.TextCellValue(
        '${_calculateCompletionRate(stats['task_completion']['completion_rate'])}%',
      ),
    ]);
  }

  /// Add student performance sheet
  static void _addStudentPerformanceSheet(
    excel.Excel excelDoc,
    Map<String, dynamic> dashboardData,
  ) {
    final performanceSheet = excelDoc['Student Performance'];
    final stats = dashboardData['stats'];

    // Add headers
    performanceSheet.appendRow([
      excel.TextCellValue('Student Name'),
      excel.TextCellValue('Registration Number'),
      excel.TextCellValue('Completed Tasks'),
      excel.TextCellValue('Total Tasks'),
      excel.TextCellValue('Completion Rate'),
      excel.TextCellValue('Status'),
    ]);

    // Add student data
    final studentPerformance = stats['student_performance'] as List<dynamic>;
    for (var student in studentPerformance) {
      final completionRate =
          double.tryParse(student['completion_rate'].toString()) ?? 0.0;
      final status =
          completionRate >= 80
              ? 'Excellent'
              : completionRate >= 50
              ? 'Good'
              : 'Needs Improvement';

      performanceSheet.appendRow([
        excel.TextCellValue(student['name'] ?? ''),
        excel.TextCellValue(student['registration_number'] ?? ''),
        excel.TextCellValue(student['completed_tasks'].toString()),
        excel.TextCellValue(student['total_tasks'].toString()),
        excel.TextCellValue('${completionRate.toStringAsFixed(1)}%'),
        excel.TextCellValue(status),
      ]);
    }
  }

  /// Add recent activities sheet
  static void _addRecentActivitiesSheet(
    excel.Excel excelDoc,
    Map<String, dynamic> dashboardData,
  ) {
    final activitiesSheet = excelDoc['Recent Activities'];
    final stats = dashboardData['stats'];

    // Add headers
    activitiesSheet.appendRow([
      excel.TextCellValue('Task Title'),
      excel.TextCellValue('Student Name'),
      excel.TextCellValue('Completion Date'),
    ]);

    // Add activity data
    final recentActivities =
        stats['recent_activities']['recent_completions'] as List<dynamic>;
    for (var activity in recentActivities) {
      activitiesSheet.appendRow([
        excel.TextCellValue(activity['task_title'] ?? ''),
        excel.TextCellValue(activity['student_name'] ?? ''),
        excel.TextCellValue(activity['completed_at'] ?? ''),
      ]);
    }
  }

  /// Calculate completion rate from raw value
  static String _calculateCompletionRate(dynamic rate) {
    try {
      if (rate is double) {
        return rate.toStringAsFixed(1);
      } else if (rate is String) {
        final doubleValue = double.tryParse(rate);
        return doubleValue != null ? doubleValue.toStringAsFixed(1) : '0.0';
      } else if (rate is int) {
        return rate.toStringAsFixed(1);
      }
      return '0.0';
    } catch (e) {
      debugPrint('Error calculating completion rate: $e');
      return '0.0';
    }
  }
}
