import 'package:flutter/material.dart';

class RecentActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;

  const RecentActivityItem({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
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
}

class RecentActivitiesList extends StatelessWidget {
  final List<dynamic> activities;

  const RecentActivitiesList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children:
            activities
                .map(
                  (activity) => Column(
                    children: [
                      RecentActivityItem(activity: activity),
                      if (activity != activities.last)
                        const Divider(height: 24),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }
}
