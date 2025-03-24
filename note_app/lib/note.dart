class Note {
  int? id;
  String title;
  String content;
  String date;

  Note ({
    this.id,
    required this.title,
    required this.content,
    required this.date
});

  factory Note.fromMap(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    date: json['date']
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
    };
  }
}