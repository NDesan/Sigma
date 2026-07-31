import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/tr.dart';

class PointsBar extends StatelessWidget {
  final UserProfile profile;

  const PointsBar({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.local_fire_department,
          color: Colors.deepOrange,
          label: '${profile.streakDays} ${context.tr('days')}',
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.star,
          color: Colors.amber.shade700,
          label: '${context.tr('level')}. ${profile.level}',
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: profile.progressToNextLevel,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      AlwaysStoppedAnimation(Colors.deepPurpleAccent),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${profile.points} / ${profile.pointsForNextLevel} pts',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
