import 'package:flutter/material.dart';
import 'package:github_api/models/github_repo.dart';

/// A card displaying repository details: stars, commits, forks, watchers,
/// language, open issues, size, and last updated.
class RepoDetailsCard extends StatelessWidget {
  final GithubRepo repo;
  final int? commitCount;

  const RepoDetailsCard({super.key, required this.repo, this.commitCount});

  static String _formatSize(int sizeKb) {
    if (sizeKb < 1024) return '${sizeKb} KB';
    final mb = sizeKb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.all(16.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(repo.ownerAvatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        repo.ownerName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (repo.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(repo.description, style: theme.textTheme.bodyLarge),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                _StatChip(
                  icon: Icons.star,
                  label: 'Stars',
                  value: repo.stars.toString(),
                ),
                if (commitCount != null)
                  _StatChip(
                    icon: Icons.commit,
                    label: 'Commits',
                    value: commitCount.toString(),
                  ),
                _StatChip(
                  icon: Icons.call_split,
                  label: 'Forks',
                  value: repo.forks.toString(),
                ),
                _StatChip(
                  icon: Icons.visibility,
                  label: 'Watchers',
                  value: repo.watchers.toString(),
                ),
                _StatChip(
                  icon: Icons.code,
                  label: 'Language',
                  value: repo.language,
                ),
                if (repo.openIssuesCount > 0)
                  _StatChip(
                    icon: Icons.bug_report_outlined,
                    label: 'Open issues',
                    value: repo.openIssuesCount.toString(),
                  ),
                if (repo.sizeKb > 0)
                  _StatChip(
                    icon: Icons.folder_outlined,
                    label: 'Size',
                    value: _formatSize(repo.sizeKb),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated ${_formatDate(repo.updatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          '$value',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
