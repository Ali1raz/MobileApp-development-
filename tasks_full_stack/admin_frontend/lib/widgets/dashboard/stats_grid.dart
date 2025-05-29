import 'package:flutter/material.dart';

class StatsGridItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const StatsGridItem({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color?.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        StatsGridItem(
          title: 'Total Students',
          value: stats['total_students']?.toString() ?? '0',
          icon: Icons.people,
          color: Colors.blue,
        ),
        StatsGridItem(
          title: 'Total Tasks',
          value: stats['total_tasks']?.toString() ?? '0',
          icon: Icons.task,
          color: Colors.orange,
        ),
        StatsGridItem(
          title: 'Completed Tasks',
          value:
              stats['task_completion']?['total_completed']?.toString() ?? '0',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatsGridItem(
          title: 'Pending Tasks',
          value: stats['task_completion']?['total_pending']?.toString() ?? '0',
          icon: Icons.pending,
          color: Colors.red,
        ),
      ],
    );
  }
}
