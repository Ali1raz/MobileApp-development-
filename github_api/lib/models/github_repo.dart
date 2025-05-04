class GithubRepo {
  final String name;
  final String fullName;
  final String description;
  final String htmlUrl;
  final int stars;
  final int forks;
  final int watchers;
  final String language;
  final String ownerName;
  final String ownerAvatarUrl;
  final DateTime updatedAt;

  GithubRepo({
    required this.name,
    required this.fullName,
    required this.description,
    required this.htmlUrl,
    required this.stars,
    required this.forks,
    required this.watchers,
    required this.language,
    required this.ownerName,
    required this.ownerAvatarUrl,
    required this.updatedAt,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String? ?? '',
      htmlUrl: json['html_url'] as String,
      stars: json['stargazers_count'] as int,
      forks: json['forks_count'] as int,
      watchers: json['watchers_count'] as int,
      language: json['language'] as String? ?? 'Unknown',
      ownerName: json['owner']['login'] as String,
      ownerAvatarUrl: json['owner']['avatar_url'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
} 