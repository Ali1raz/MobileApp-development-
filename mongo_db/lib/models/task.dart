class Task {
  final String? id;
  String title;
  int priority;
  bool completed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;

  Task({
    this.id,
    required this.title,
    required this.priority,
    this.completed = false,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['_id'],
      title: json['title'] ?? '',
      priority: json['priority'] ?? 0,
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'priority': priority,
      'completed': completed,
    };
  }
}
