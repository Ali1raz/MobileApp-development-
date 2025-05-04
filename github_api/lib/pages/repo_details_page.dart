import 'package:flutter/material.dart';
import 'package:github_api/models/github_repo.dart';
import 'package:github_api/services/github_service.dart';
import 'package:github_api/utils/app_errors.dart';
import 'package:url_launcher/url_launcher.dart';

class RepoDetailsPage extends StatefulWidget {
  final String fullName;

  const RepoDetailsPage({
    super.key,
    required this.fullName,
  });

  @override
  State<RepoDetailsPage> createState() => _RepoDetailsPageState();
}

class _RepoDetailsPageState extends State<RepoDetailsPage> {
  final GithubService _githubService = GithubService();
  bool isLoading = true;
  AppError? error;
  GithubRepo? repo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repoData = await _githubService.fetchRepoDetails(widget.fullName);
      setState(() {
        repo = repoData;
        isLoading = false;
      });
    } on AppError catch (e) {
      setState(() {
        error = e;
        isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!.message));
    }

    if (repo == null) {
      return const Center(child: Text('Repository not found'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(repo!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchUrl(repo!.htmlUrl),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(repo!.ownerAvatarUrl),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    repo!.ownerName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                repo!.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children: [
                  _buildStat(Icons.star, repo!.stars.toString()),
                  _buildStat(Icons.call_split, repo!.forks.toString()),
                  _buildStat(Icons.visibility, repo!.watchers.toString()),
                  _buildStat(Icons.code, repo!.language),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Last updated: ${_formatDate(repo!.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(value),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 