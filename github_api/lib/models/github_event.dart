class GithubEvent {
  final String type;
  final String repoName;
  final String actorAvatarUrl;
  final String createdAt;
  final List<String> commitMessages;

  GithubEvent({
    required this.type,
    required this.repoName,
    required this.actorAvatarUrl,
    required this.createdAt,
    required this.commitMessages,
  });

  factory GithubEvent.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>? ?? {};
    final commits = payload['commits'] as List<dynamic>? ?? [];
    final commitMessages = commits.map((c) => (c as Map<String, dynamic>)['message'] as String? ?? '').toList();

    final repo = json['repo'] as Map<String, dynamic>?;
    final actor = json['actor'] as Map<String, dynamic>?;

    return GithubEvent(
      type: json['type'] as String? ?? 'Unknown',
      repoName: repo?['name'] as String? ?? 'Unknown',
      actorAvatarUrl: actor?['avatar_url'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      commitMessages: commitMessages,
    );
  }
} 