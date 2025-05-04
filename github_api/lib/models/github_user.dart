class GithubUser {
  final String username;
  final String name;
  final String? bio;
  final String avatarUrl;
  final int followers;
  final int following;
  final String htmlUrl;

  GithubUser({
    required this.username,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.followers,
    required this.following,
    required this.htmlUrl,
  });

  factory GithubUser.fromJson(Map<String, dynamic> json) {
    return GithubUser(
      username: json['login'] as String,
      name: json['name'] as String? ?? json['login'],
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String,
      followers: json['followers'] as int,
      following: json['following'] as int,
      htmlUrl: json['html_url'] as String,
    );
  }
}
