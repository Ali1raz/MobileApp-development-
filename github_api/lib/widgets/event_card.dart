import 'package:flutter/material.dart';
import 'package:github_api/models/github_event.dart';
import 'package:github_api/utils/timesago.dart';

class EventCard extends StatelessWidget {
  final GithubEvent event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          title: Text(
            event.repoName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          leading: CircleAvatar(
            maxRadius: 20,
            child: Image.network(event.actorAvatarUrl),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Type: ${event.type}"),
              const SizedBox(height: 10),
              Text(timeAgoFromIso(event.createdAt)),
              if (event.commitMessages.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...event.commitMessages.map(
                  (msg) => Text(
                    "• $msg",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
