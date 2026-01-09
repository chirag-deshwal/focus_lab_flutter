import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../widgets/daily_tasks.dart';
import '../widgets/habit_grid.dart';
import '../widgets/overall_progress.dart';
import '../widgets/success_line_chart.dart';
import '../widgets/success_score_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Focus Lab",
            style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              appState.toggleTheme();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 60,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? Colors.grey.shade800 : Colors.blue.shade100,
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: isDark ? 30 : 2,
                    top: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) {
                          return RotationTransition(
                            turns: child.key == const ValueKey('dark_icon')
                                ? Tween<double>(begin: 0.75, end: 1)
                                    .animate(anim)
                                : Tween<double>(begin: 0.75, end: 1)
                                    .animate(anim),
                            child: ScaleTransition(scale: anim, child: child),
                          );
                        },
                        child: Icon(
                          isDark
                              ? Icons.nightlight_round
                              : Icons.wb_sunny_rounded,
                          key: ValueKey(isDark ? 'dark_icon' : 'light_icon'),
                          color: isDark ? Colors.blueGrey : Colors.orange,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            SizedBox(
              height: 250,
              child: isMobile
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        SizedBox(
                            width: 300,
                            child:
                                SuccessScoreCard()), // Reordered as per image
                        SizedBox(width: 20),
                        SizedBox(width: 300, child: OverallProgress()),
                        SizedBox(width: 20),
                        SizedBox(width: 300, child: SuccessLineChart()),
                      ],
                    )
                  : Row(
                      children: const [
                        Expanded(child: SuccessScoreCard()),
                        SizedBox(width: 20),
                        Expanded(child: OverallProgress()),
                        SizedBox(width: 20),
                        Expanded(child: SuccessLineChart()),
                      ],
                    ),
            ),
            const SizedBox(height: 30),
            // Bottom Split Section
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1), // Light grey background
                borderRadius: BorderRadius.circular(30),
              ),
              child: isMobile
                  ? Column(
                      children: [
                        // Tasks on top for mobile (as per image)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: DayTaskPanel(),
                        ),
                        // Habit Tracker below
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Habit Tracker",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const HabitGrid(),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Habit Tracker (White Card)
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Habit Tracker",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const HabitGrid(),
                              ],
                            ),
                          ),
                        ),
                        // Right: Tasks (Transparent/Grey)
                        const Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 10),
                            child: DayTaskPanel(),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
