import 'package:flutter/material.dart';
import 'habit.dart';
import 'task.dart';

class AppState extends ChangeNotifier {
  final List<Habit> _habits = [
    Habit(id: '1', title: 'Wake up at 05:00', iconEmoji: '⏰'),
    Habit(id: '2', title: 'Gym', iconEmoji: '💪'),
    Habit(id: '3', title: 'Reading / Learning', iconEmoji: '📖'),
    Habit(id: '4', title: 'Day Planning', iconEmoji: '📅'),
    Habit(id: '5', title: 'Budget Tracking', iconEmoji: '💰'),
    Habit(id: '6', title: 'Project Work', iconEmoji: '🎯'),
    Habit(id: '7', title: 'No Alcohol', iconEmoji: '🚫'),
    Habit(id: '8', title: 'Social Media Detox', iconEmoji: '🌿'),
    Habit(id: '9', title: 'Goal Journaling', iconEmoji: '📔'),
    Habit(id: '10', title: 'Cold Shower', iconEmoji: '🚿'),
  ];

  final List<AppTask> _tasks = [
    AppTask(
        id: '1',
        title: 'Film content for the new project',
        date: DateTime.now()),
    AppTask(id: '2', title: 'Water the plants', date: DateTime.now()),
    AppTask(id: '3', title: 'Meet up with friends', date: DateTime.now()),
    AppTask(
        id: '4',
        title: 'Check email',
        date: DateTime.now().add(const Duration(days: 1))),
    AppTask(
        id: '5',
        title: 'Reply to urgent matters',
        date: DateTime.now().add(const Duration(days: 1))),
    AppTask(
        id: '6',
        title: 'Post about the company',
        date: DateTime.now().add(const Duration(days: 2))),
  ];

  DateTime _selectedDate = DateTime.now();
  bool _isDarkMode = false;

  List<Habit> get habits => _habits;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  List<AppTask> get tasksForSelectedDate {
    final normalizedSelected =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return _tasks.where((t) {
      final normalizedTask = DateTime(t.date.year, t.date.month, t.date.day);
      return normalizedTask.isAtSameMomentAs(normalizedSelected);
    }).toList();
  }

  DateTime get selectedDate => _selectedDate;

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void toggleHabit(String habitId, DateTime date) {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    habit.toggleCompletion(date);
    notifyListeners();
  }

  void toggleTask(String taskId) {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.toggle();
    notifyListeners();
  }

  void addTask(String title, DateTime date) {
    _tasks.add(AppTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        date: date));
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void updateHabitTitle(String id, String newTitle) {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      _habits[index] = _habits[index].copyWith(title: newTitle);
      notifyListeners();
    }
  }

  Map<String, dynamic> getWeeklyProgressStats() {
    // Determine the start of the week (Monday) for the selected date
    // DateTime.weekday returns 1 for Mon, 7 for Sun
    final startOfWeek = _selectedDate
        .subtract(Duration(days: _selectedDate.weekday - 1))
        .copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0); // Strip time

    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));

    double calculateProgressForWeek(DateTime start) {
      int completedCount = 0;
      for (int i = 0; i < 7; i++) {
        final day = start.add(Duration(days: i));
        // Check each habit
        for (var habit in _habits) {
          if (habit.isCompletedOn(day)) {
            completedCount++;
          }
        }
      }
      if (_habits.isEmpty) return 0.0;
      return completedCount / (_habits.length * 7);
    }

    final currentProgress = calculateProgressForWeek(startOfWeek);
    final previousProgress = calculateProgressForWeek(startOfLastWeek);

    // Calculate daily counts for the chart
    List<double> dailyData = [];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      int count = 0;
      for (var habit in _habits) {
        if (habit.isCompletedOn(day)) {
          count++;
        }
      }
      dailyData.add(count.toDouble());
    }

    return {
      'currentProgress': currentProgress,
      'previousProgress': previousProgress,
      'dailyData': dailyData,
    };
  }

  double get dailySuccessScore {
    int totalHabits = _habits.length;
    int completedHabits =
        _habits.where((h) => h.isCompletedOn(_selectedDate)).length;

    // Filter tasks for the selected date
    final tasksForDay = tasksForSelectedDate;
    int totalTasks = tasksForDay.length;
    int completedTasks = tasksForDay.where((t) => t.isCompleted).length;

    int total = totalHabits + totalTasks;
    int completed = completedHabits + completedTasks;

    if (total == 0) return 0.0;
    return completed / total;
  }

  List<Map<String, dynamic>> getSuccessFailureHistory() {
    // Return last 7 days including today
    // List of {date, success, failure}
    List<Map<String, dynamic>> history = [];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));

      // Habits for day
      int completedHabits = _habits.where((h) => h.isCompletedOn(day)).length;
      int failedHabits = _habits.length - completedHabits;

      // Tasks for day
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final tasksForDay = _tasks.where((t) {
        final normalizedTask = DateTime(t.date.year, t.date.month, t.date.day);
        return normalizedTask.isAtSameMomentAs(normalizedDay);
      }).toList();

      int completedTasks = tasksForDay.where((t) => t.isCompleted).length;
      int failedTasks = tasksForDay.length - completedTasks;

      history.add({
        'day': day,
        'success': completedHabits + completedTasks,
        'failure': failedHabits + failedTasks,
      });
    }
    return history;
  }
}
