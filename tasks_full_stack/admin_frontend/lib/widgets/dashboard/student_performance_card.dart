import 'package:flutter/material.dart';

class StudentPerformanceCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentPerformanceCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
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
      debugPrint('Error parsing student completion rate: $e');
    }

    final status =
        completionRate >= 80
            ? 'Excellent'
            : completionRate >= 50
            ? 'Good'
            : 'Needs Improvement';

    final statusColor =
        completionRate >= 80
            ? Colors.green
            : completionRate >= 50
            ? Colors.orange
            : Colors.red;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/student-details',
          arguments: student['registration_number'],
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 4),
                      Text(
                        student['registration_number'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Completed Tasks',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student['completed_tasks'] ?? 0}/${student['total_tasks'] ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Completion Rate',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${completionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
