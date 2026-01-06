class AppTask {
  final String id;
  final String title;
  final DateTime date;
  bool isCompleted;

  AppTask({
    required this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory AppTask.fromJson(Map<String, dynamic> json) {
    return AppTask(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  void toggle() {
    isCompleted = !isCompleted;
  }
}
