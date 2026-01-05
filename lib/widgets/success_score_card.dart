import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../theme/colors.dart';

class SuccessScoreCard extends StatelessWidget {
  const SuccessScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final score = appState.dailySuccessScore;
    final percentage = (score * 100).toInt();

    return Container(
      // Height handled by parent
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Success score",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          Text(
            "Keep up the momentum!",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          Expanded(
            child: Center(
              child: CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 10.0,
                animation: true,
                percent: score,
                center: Text(
                  "$percentage%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: AppColors.primaryGreen,
                backgroundColor: AppColors.lightGreen.withAlpha(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
