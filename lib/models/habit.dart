class Habit {
  final String id;
  final String title;
  final String iconEmoji; // Using simpler emoji for icons as seen in the image
  final Set<DateTime> completedDays;

  Habit({
    required this.id,
    required this.title,
    required this.iconEmoji,
    Set<DateTime>? completedDays,
  }) : completedDays = completedDays ?? {};

  bool isCompletedOn(DateTime date) {
    // Normalize date to remove time
    final normalized = DateTime(date.year, date.month, date.day);
    return completedDays.contains(normalized);
  }

  void toggleCompletion(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (completedDays.contains(normalized)) {
      completedDays.remove(normalized);
    } else {
      completedDays.add(normalized);
    }
  }

  Habit copyWith({
    String? id,
    String? title,
    String? iconEmoji,
    Set<DateTime>? completedDays,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      completedDays: completedDays ?? this.completedDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconEmoji': iconEmoji,
      'completedDays':
          completedDays.map((date) => date.toIso8601String()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      title: json['title'],
      iconEmoji: json['iconEmoji'],
      completedDays: (json['completedDays'] as List<dynamic>?)
              ?.map((dateStr) => DateTime.parse(dateStr))
              .toSet() ??
          {},
    );
  }
}
