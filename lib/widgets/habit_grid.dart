import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';

class HabitGrid extends StatefulWidget {
  const HabitGrid({super.key});

  @override
  State<HabitGrid> createState() => _HabitGridState();
}

class _HabitGridState extends State<HabitGrid> {
  final ScrollController _scrollController = ScrollController();
  double? _lastWidth;
  DateTime? _lastSelectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!mounted) return;
    final appState = Provider.of<AppState>(context, listen: false);

    // Ensure we have a selection (Auto-select today if needed, though AppState handles init)
    // If logic needed to "auto select current date if not selected", AppState already defaults to Now.
    // Use the same generation logic as build
    final today = DateTime.now();
    final days = List.generate(
        14, (index) => today.subtract(Duration(days: 13 - index)));

    final selectedIndex = days.indexWhere((d) =>
        d.year == appState.selectedDate.year &&
        d.month == appState.selectedDate.month &&
        d.day == appState.selectedDate.day);

    if (selectedIndex != -1 && _scrollController.hasClients) {
      final itemWidth = 50.0;
      final offset = selectedIndex * itemWidth;

      try {
        final viewport = _scrollController.position.viewportDimension;
        final maxScroll = _scrollController.position.maxScrollExtent;

        // Center the selected item
        // item center = offset + itemWidth/2
        // viewport center = viewport/2
        // scroll needed = item center - viewport center
        double target = (offset + itemWidth / 2) - (viewport / 2);

        // Clamp to valid range
        target = target.clamp(0.0, maxScroll);

        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        // Handle cases where layout might not be ready
        print("Scroll error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final habits = appState.habits;
    final screenWidth = MediaQuery.of(context).size.width;

    // Trigger scroll if width or selection changes
    if (_lastWidth != screenWidth ||
        _lastSelectedDate != appState.selectedDate) {
      _lastWidth = screenWidth;
      _lastSelectedDate = appState.selectedDate;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }

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
                  controller: _scrollController,
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
