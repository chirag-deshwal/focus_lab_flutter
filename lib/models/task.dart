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

  void toggle() {
    isCompleted = !isCompleted;
  }
}
