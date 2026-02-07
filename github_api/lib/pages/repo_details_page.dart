import 'package:flutter/material.dart';
import 'package:github_api/models/github_repo.dart';
import 'package:github_api/services/github_service.dart';
import 'package:github_api/utils/app_errors.dart';
import 'package:github_api/widgets/repo_details_card.dart';
import 'package:url_launcher/url_launcher.dart';

class RepoDetailsPage extends StatefulWidget {
  final String fullName;

  const RepoDetailsPage({super.key, required this.fullName});

  @override
  State<RepoDetailsPage> createState() => _RepoDetailsPageState();
}

class _RepoDetailsPageState extends State<RepoDetailsPage> {
  final GithubService _githubService = GithubService();
  bool isLoading = true;
  AppError? error;
  GithubRepo? repo;
  int? commitCount;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repoData = await _githubService.fetchRepoDetails(widget.fullName);
      final commits = await _githubService.fetchRepoCommitCount(
        widget.fullName,
      );
      setState(() {
        repo = repoData;
        commitCount = commits;
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
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch URL')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: SafeArea(child: const Center(child: CircularProgressIndicator())),
      );
    }

    if (error != null) {
      return Scaffold(
        body: SafeArea(child: Center(child: Text(error!.message))),
      );
    }

    if (repo == null) {
      return Scaffold(
        body: SafeArea(
          child: const Center(child: Text('Repository not found')),
        ),
      );
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: RepoDetailsCard(repo: repo!, commitCount: commitCount),
        ),
      ),
    );
  }
}
