import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';

class OverallProgress extends StatelessWidget {
  const OverallProgress({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final stats = appState.getWeeklyProgressStats();

    final List<double> dailyData = stats['dailyData'];

    // Use total habit count as maxY for the chart (or at least a reasonable number)
    final double maxPossible =
        appState.habits.isNotEmpty ? appState.habits.length.toDouble() : 10.0;
    // Ensure maxY is at least 1 to avoid division by zero errors in chart
    final double maxY = maxPossible > 0 ? maxPossible : 1.0;

    return Container(
      // Height handled by parent or flex
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
            20), // Sharper or smoother? Wireframe looks rounded.
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overall progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        );
                        String text;
                        // Dynamically calculate day names based on last 7 days ending today?
                        // Or fixed S, M, T, W...? The implementation of getWeeklyProgressStats returns last 7 days starting from Monday or relative.
                        // Ideally we grab the days from stats or just show generic M T W T F S S mapping if the data aligns.
                        // Assuming dailyData is 7 days.
                        int index = value.toInt();
                        // Let's assume standard week starting Monday for now, or use a list of chars if we want dynamic but simple.
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (index >= 0 && index < days.length) {
                          text = days[index];
                        } else {
                          text = '';
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  double val =
                      index < dailyData.length ? dailyData[index] : 0.0;
                  return makeGroupData(index, val, maxY);
                }),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y, double max) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primaryGreen,
          width: 22, // Increased width
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8), // Increased rounded corners
            topRight: Radius.circular(8),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: max,
            color: AppColors.lightGreen.withAlpha(50),
          ),
        ),
      ],
    );
  }
}
