import 'package:flutter/material.dart';
import 'package:github_api/models/github_event.dart';
import 'package:github_api/pages/repo_details_page.dart';
import 'package:github_api/pages/user_details_page.dart';
import 'package:github_api/services/github_service.dart';
import 'package:github_api/utils/app_errors.dart';
import 'package:github_api/widgets/event_card.dart';
import 'package:github_api/widgets/event_skeleton.dart';
import 'package:github_api/widgets/search_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(title: "Github Activity"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final GithubService _githubService = GithubService();
  bool isLoading = false;
  AppError? error;
  List<GithubEvent> events = [];

  Future<void> fetchData(String username) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await _githubService.fetchUserEvents(username);
      setState(() {
        events = response.take(5).toList();
      });
    } on AppError catch (e) {
      setState(() {
        error = e;
        events = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.secondary.withAlpha(200),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.secondary;
    final errorTextColor = theme.colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              SearchForm(
                controller: _controller,
                onSearch: () => fetchData(_controller.text.trim()),
                formKey: _formKey,
              ),
              const SizedBox(height: 10),
              if (isLoading)
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => const EventSkeleton(),
                  ),
                )
              else if (events.isNotEmpty)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => fetchData(_controller.text.trim()),
                          child: ListView.builder(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => UserDetailsPage(
                                      username: _controller.text.trim(),
                                    ),
                              ),
                            );
                          },
                          child: const Text('View All Activity'),
                        ),
                      ),
                    ],
                  ),
                )
              else if (error != null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getErrorIcon(error!), size: 48, color: errorColor),
                      const SizedBox(height: 16),
                      Text(
                        error!.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: errorTextColor),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getErrorIcon(AppError error) {
    switch (error) {
      case AppError.userNotFound:
        return Icons.person_off;
      case AppError.networkError:
        return Icons.wifi_off;
      case AppError.noActivity:
        return Icons.event_busy;
      case AppError.unknownError:
        return Icons.error_outline;
    }
  }
}
