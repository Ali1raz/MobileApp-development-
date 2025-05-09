class Task {
  final String? id;
  String title;
  int priority;
  bool completed;

  Task({
    this.id,
    required this.title,
    required this.priority,
    this.completed = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'] ?? '',
      priority: json['priority'] ?? 0,
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'priority': priority,
      'completed': completed,
    };
  }
}
