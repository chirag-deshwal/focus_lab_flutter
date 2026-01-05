import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';

class HabitGrid extends StatelessWidget {
  const HabitGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final habits = appState.habits;

    // Generate last 30 days for example
    final today = DateTime.now();
    final days = List.generate(
        14, (index) => today.subtract(Duration(days: 13 - index)));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Fixed Habit Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height: 50), // Header spacer, increased for larger dates
                  ...habits.map((habit) => Container(
                        height: 50, // Increased height for larger rows
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                final controller =
                                    TextEditingController(text: habit.title);
                                return AlertDialog(
                                  title: const Text("Edit Habit"),
                                  content: TextField(
                                    controller: controller,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                        labelText: "Habit Title"),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (controller.text.isNotEmpty) {
                                          appState.updateHabitTitle(
                                              habit.id, controller.text);
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Save"),
                                    )
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "${habit.iconEmoji} ${habit.title}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    14, // Maintained/slightly tweaked text size
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )),
                ],
              ),
              // Scrollable Days
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: days.map((date) {
                      final isSelected =
                          date.day == appState.selectedDate.day &&
                              date.month == appState.selectedDate.month &&
                              date.year == appState.selectedDate.year;

                      return GestureDetector(
                        onTap: () => appState.updateSelectedDate(date),
                        child: Container(
                          width: 50, // Widened column
                          color: isSelected
                              ? AppColors.lightGreen.withAlpha(100)
                              : Colors.transparent,
                          child: Column(
                            children: [
                              // Date Header
                              SizedBox(
                                height: 50,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('E')
                                          .format(date)
                                          .substring(0, 2),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color),
                                    ),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? AppColors.darkGreen
                                              : Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color),
                                    ),
                                  ],
                                ),
                              ),
                              // Checkboxes
                              ...habits.map((habit) {
                                final isCompleted = habit.isCompletedOn(date);
                                return Container(
                                  height: 50, // Match row height
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () =>
                                        appState.toggleHabit(habit.id, date),
                                    child: Container(
                                      width: 32, // Larger checkbox
                                      height: 32, // Larger checkbox
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? AppColors.primaryGreen
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isCompleted
                                              ? AppColors.primaryGreen
                                              : Colors.grey.withAlpha(
                                                  100), // Lighter border for dark mode compatibility
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            8), // Slightly more rounded
                                      ),
                                      child: isCompleted
                                          ? const Icon(Icons.check,
                                              size: 24,
                                              color: Colors
                                                  .white) // Larger check icon
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
