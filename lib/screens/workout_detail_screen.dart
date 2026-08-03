import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutDetailScreen({super.key, required this.session});

  String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];
    final hour = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day} · $hour:$min $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final hasEndTime = session.endTime != null;
    final duration = hasEndTime ? session.duration : null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatDateTime(session.dateTime),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _InfoTile(
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: duration != null
                          ? _formatDuration(duration)
                          : 'N/A',
                    ),
                    const SizedBox(width: 24),
                    _InfoTile(
                      icon: Icons.fitness_center,
                      label: 'Exercises',
                      value: '${session.exercises.length}',
                    ),
                    const SizedBox(width: 24),
                    _InfoTile(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Total Vol.',
                      value:
                          '${session.totalVolume.toStringAsFixed(0)} kg',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...session.exercises.map((entry) =>
                _ExerciseDetailCard(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: theme.hintColor, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDetailCard extends StatelessWidget {
  final ExerciseEntry entry;

  const _ExerciseDetailCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.exerciseName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _StatBadge(
                  label:
                      'Max: ${entry.maxWeight.toStringAsFixed(1)} kg',
                ),
                const SizedBox(width: 12),
                _StatBadge(
                  label: 'Total: ${entry.totalReps} reps',
                ),
                const SizedBox(width: 12),
                _StatBadge(
                  label:
                      'Vol: ${entry.totalVolume.toStringAsFixed(0)} kg',
                ),
              ],
            ),
            Divider(color: theme.dividerColor),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                      width: 32,
                      child: Text("SET",
                          style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("KG",
                          style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      child: Text("REPS",
                          style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text("NOTES",
                          style: TextStyle(
                              color: theme.hintColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            ...List.generate(entry.sets.length, (index) {
              final set = entry.sets[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text(
                        "#${index + 1}",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${set.weightKg.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        set.reps.toString(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        set.notes ?? '',
                        style: TextStyle(
                          color: set.notes != null && set.notes!.isNotEmpty
                              ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
                              : theme.hintColor.withOpacity(0.5),
                          fontSize: 13,
                          fontStyle: set.notes != null && set.notes!.isNotEmpty
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;

  const _StatBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
