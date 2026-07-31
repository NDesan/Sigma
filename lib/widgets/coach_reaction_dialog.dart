import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/tr.dart';

class CoachReactionDialog extends StatelessWidget {
  final List<ExerciseComparisonResult> comparisonResults;
  final String coachFeedbackText;
  final VoidCallback onClose;

  const CoachReactionDialog({
    super.key,
    required this.comparisonResults,
    required this.coachFeedbackText,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRegression = comparisonResults.any((r) => r.status == PerformanceStatus.regressed);
    final hasImprovement = comparisonResults.any((r) => r.status == PerformanceStatus.improved);

    Color headerColor;
    String headerTitle;
    IconData headerIcon;

    if (hasRegression) {
      headerColor = Colors.redAccent;
      headerTitle = context.tr('coachRecap');
      headerIcon = Icons.warning_amber_rounded;
    } else if (hasImprovement) {
      headerColor = Colors.green;
      headerTitle = context.tr('workoutAcceptable');
      headerIcon = Icons.thumb_up_alt_rounded;
    } else {
      headerColor = Colors.orangeAccent;
      headerTitle = context.tr('workoutLogged');
      headerIcon = Icons.fitness_center;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF1E1E2C),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: headerColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(headerIcon, color: headerColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      headerTitle,
                      style: TextStyle(
                        color: headerColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Avatar Visual representation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: headerColor.withOpacity(0.15),
                  border: Border.all(color: headerColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    hasRegression ? "👿" : (hasImprovement ? "⚡" : "😐"),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Coach Dialogue Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  coachFeedbackText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Detailed Exercise Stats Chips
              Column(
                children: comparisonResults.map((res) {
                  Color chipColor;
                  String iconStr;
                  String badgeText;

                  switch (res.status) {
                    case PerformanceStatus.improved:
                      chipColor = Colors.greenAccent;
                      iconStr = "▲";
                      badgeText = "+${res.volumeDeltaPercent.abs().toStringAsFixed(1)}% ${context.tr('vol')}";
                      break;
                    case PerformanceStatus.regressed:
                      chipColor = Colors.redAccent;
                      iconStr = "▼";
                      badgeText = "-${res.volumeDeltaPercent.abs().toStringAsFixed(1)}% ${context.tr('vol')}";
                      break;
                    case PerformanceStatus.stagnant:
                      chipColor = Colors.amberAccent;
                      iconStr = "=";
                      badgeText = context.tr('stagnant');
                      break;
                    case PerformanceStatus.firstTime:
                      chipColor = Colors.lightBlueAccent;
                      iconStr = "★";
                      badgeText = context.tr('newBaseline');
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              res.exerciseName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: chipColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "$iconStr $badgeText",
                              style: TextStyle(
                                color: chipColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onClose();
                  },
                  child: Text(
                    context.tr('acceptAndGrind'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
