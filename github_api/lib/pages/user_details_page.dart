import 'package:flutter/material.dart';
import 'package:github_api/models/github_event.dart';
import 'package:github_api/models/github_repo.dart';
import 'package:github_api/models/github_user.dart';
import 'package:github_api/pages/repo_details_page.dart';
import 'package:github_api/services/github_service.dart';
import 'package:github_api/utils/app_errors.dart';
import 'package:github_api/widgets/event_card.dart';
import 'package:github_api/widgets/repo_card.dart';

class UserDetailsPage extends StatefulWidget {
  final String username;

  const UserDetailsPage({super.key, required this.username});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage>
    with SingleTickerProviderStateMixin {
  final GithubService _githubService = GithubService();
  late TabController _tabController;
  bool isLoading = true;
  bool isPaginationLoading = false; // for pagination
  AppError? error;
  GithubUser? user;
  List<GithubRepo> repos = [];
  List<GithubEvent> events = [];
  int currentPage = 1;
  bool hasMore = true;
  Map<int, List<GithubEvent>> pageCache = {}; // for caching

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPage(int newPage) async {
    if (newPage < 1 || isPaginationLoading) return;

    // Load from cache if available
    if (pageCache.containsKey(newPage)) {
      setState(() {
        events = pageCache[newPage]!;
        currentPage = newPage;
        hasMore = events.length == GithubService.perPage;
      });
      return;
    }

    setState(() => isPaginationLoading = true);

    try {
      final newEvents = await _githubService.fetchUserEvents(
        widget.username,
        page: newPage,
      );

      pageCache[newPage] = newEvents; // Update cache
      setState(() {
        events = newEvents;
        currentPage = newPage;
        hasMore = newEvents.length == GithubService.perPage;
        isPaginationLoading = false;
      });
    } on AppError catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
      setState(() => isPaginationLoading = false);
    }
  }

  Future<void> _loadData() async {
    try {
      final userData = await _githubService.fetchUserDetails(widget.username);
      final reposData = await _githubService.fetchUserRepos(widget.username);
      List<GithubEvent> eventsData = [];
      try {
        eventsData = await _githubService.fetchUserEvents(widget.username);
      } on AppError catch (e) {
        if (e != AppError.noActivity) rethrow;
      }

      setState(() {
        user = userData;
        repos = reposData;
        pageCache[1] = eventsData;
        events = eventsData;
        isLoading = false;
        hasMore = eventsData.length == GithubService.perPage;
      });
    } on AppError catch (e) {
      setState(() {
        error = e;
        isLoading = false;
      });
    }
  }

  void _navigateToRepoDetails(String fullName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RepoDetailsPage(fullName: fullName),
      ),
    );
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

    if (user == null) {
      return Scaffold(
        body: SafeArea(child: const Center(child: Text('User not found'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user!.username),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Repos'), Tab(text: 'Events')],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildUserInfo(),
            const Divider(height: 1),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildReposList(), _buildEventsList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(user!.avatarUrl),
          ),
          const SizedBox(height: 16),
          Text(user!.name, style: Theme.of(context).textTheme.headlineSmall),
          if (user!.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              user!.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat('Followers', user!.followers),
              _buildStat('Following', user!.following),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildReposList() {
    if (repos.isEmpty) {
      return const Center(child: Text('No public repos'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: repos.length,
      itemBuilder: (context, index) {
        final repo = repos[index];
        return RepoCard(
          repo: repo,
          onTap: () => _navigateToRepoDetails(repo.fullName),
        );
      },
    );
  }

  Widget _buildEventsList() {
    return Column(
      children: [
        Expanded(
          child:
              isPaginationLoading
                  ? const Center(child: CircularProgressIndicator())
                  : events.isEmpty
                  ? const Center(child: Text('No events'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        onTap: () => _navigateToRepoDetails(event.repoName),
                      );
                    },
                  ),
        ),
        if (!isPaginationLoading)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage != 1 ? () => _loadPage(1) : null,
                    icon: const Icon(Icons.first_page),
                    tooltip: 'First page',
                  ),
                  IconButton(
                    onPressed:
                        currentPage > 1
                            ? () => _loadPage(currentPage - 1)
                            : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Page $currentPage',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    onPressed:
                        hasMore ? () => _loadPage(currentPage + 1) : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
