import 'package:flutter/material.dart';
import 'package:github_api/models/github_event.dart';
import 'package:github_api/models/github_user.dart';
import 'package:github_api/services/github_service.dart';
import 'package:github_api/utils/app_errors.dart';
import 'package:github_api/widgets/event_card.dart';

class UserDetailsPage extends StatefulWidget {
  final String username;

  const UserDetailsPage({super.key, required this.username});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final GithubService _githubService = GithubService();
  bool isLoading = true;
  bool isPaginationLoading = false; // for pagination
  AppError? error;
  GithubUser? user;
  List<GithubEvent> events = [];
  int currentPage = 1;
  bool hasMore = true;
  Map<int, List<GithubEvent>> pageCache = {}; // for caching

  @override
  void initState() {
    super.initState();
    _loadData();
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
      final eventsData = await _githubService.fetchUserEvents(widget.username);

      setState(() {
        user = userData;
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!.message));
    }

    if (user == null) {
      return const Center(child: Text('User not found'));
    }

    return Scaffold(
      appBar: AppBar(title: Text(user!.username)),
      body: SingleChildScrollView(
        child: Column(
          children: [_buildUserInfo(), const Divider(), _buildEventsList()],
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

  Widget _buildEventsList() {
    return Column(
      children: [
        ...events.map((event) => EventCard(event: event)),
        if (isPaginationLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: currentPage != 1 ? () => _loadPage(1) : null,
                  child: const Icon(Icons.first_page),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      currentPage > 1 ? () => _loadPage(currentPage - 1) : null,
                  child: const Icon(Icons.arrow_back_ios),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: hasMore ? () => _loadPage(currentPage + 1) : null,
                  child: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
