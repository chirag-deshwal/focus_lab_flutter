import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:percent_indicator/percent_indicator.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';
import '../models/task.dart';

class DayTaskPanel extends StatefulWidget {
  const DayTaskPanel({super.key});

  @override
  State<DayTaskPanel> createState() => _DayTaskPanelState();
}

class _DayTaskPanelState extends State<DayTaskPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;
  bool _wasAllCompleted = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final date = appState.selectedDate;
    final tasks = appState.tasksForSelectedDate;

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    // Trigger celebration if newly completed
    if (totalCount > 0 && progress == 1.0 && !_wasAllCompleted) {
      _wasAllCompleted = true;
      _celebrationController.forward(from: 0);
    } else if (progress < 1.0) {
      _wasAllCompleted = false;
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Area
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE').format(date),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      Text(
                        DateFormat('dd.MM.yyyy').format(date),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      CircularPercentIndicator(
                        radius: 25.0, // Smaller ring
                        lineWidth: 6.0,
                        animation: true,
                        animateFromLastPercent: true,
                        percent: progress,
                        center: Text(
                          "${(progress * 100).toInt()}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: AppColors.primaryGreen,
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                      child: Text("No tasks for today",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color))),
                ),

              // Task List
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(
                    bottom: 80), // Prevent overlap with FAB
                children: tasks
                    .map((task) => TaskTile(
                          task: task,
                          onToggle: () =>
                              _confirmToggle(context, appState, task.id),
                          onDelete: () => appState.deleteTask(task.id),
                        ))
                    .toList(),
              ),

              // Add Button
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton.extended(
                    backgroundColor: const Color(0xFF333333),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    onPressed: () => _showAddTaskDialog(context, appState),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("NEW",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_wasAllCompleted)
          Positioned.fill(
            child: IgnorePointer(
              child: ConfettiWidget(controller: _celebrationController),
            ),
          ),
      ],
    );
  }

  void _confirmToggle(BuildContext context, AppState appState, String taskId) {
    final now = DateTime.now();
    final selected = appState.selectedDate;
    final isToday = selected.year == now.year &&
        selected.month == now.month &&
        selected.day == now.day;

    if (isToday) {
      appState.toggleTask(taskId);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Update Task?"),
          content: const Text(
              "You are updating a task for a different date. Do you want to proceed?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                appState.toggleTask(taskId);
                Navigator.pop(ctx);
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      );
    }
  }

  void _showAddTaskDialog(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Task"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter task name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                appState.addTask(controller.text, appState.selectedDate);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final AppTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.primaryGreen
                      : (Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha(100) ??
                          Colors.grey),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 16,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.isCompleted
                      ? Colors.grey
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                child: Text(task.title),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 20, color: Colors.grey.withOpacity(0.6)),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class ConfettiWidget extends AnimatedWidget {
  const ConfettiWidget({super.key, required AnimationController controller})
      : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as AnimationController;
    return CustomPaint(
      painter: ConfettiPainter(animation.value),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double progress;
  final Random _random = Random();

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final paint = Paint();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxDist = size.width * 0.8;

    for (int i = 0; i < 50; i++) {
      // Deterministic random based on index
      final r = Random(i);
      final angle = r.nextDouble() * 2 * pi;
      final dist = r.nextDouble() * maxDist * progress;
      final radius = r.nextDouble() * 5 + 2;

      // Color
      final colorFn = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple
      ];
      paint.color =
          colorFn[r.nextInt(colorFn.length)].withOpacity(1 - progress);

      final x = centerX + cos(angle) * dist;
      final y =
          centerY + sin(angle) * dist - (progress * 100); // Move up slightly

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw "Well Done!" text
    if (progress < 0.8) {
      final textSpan = TextSpan(
        text: 'Well Done!',
        style: TextStyle(
          color: AppColors.primaryGreen.withOpacity((1 - progress).clamp(0, 1)),
          fontSize: 40 * (0.5 + progress), // Scale up
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(centerX - textPainter.width / 2,
              centerY - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
