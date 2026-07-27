import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PointsService>().profile;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ta progression',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatCard(
                  label: 'Streak actuel',
                  value: '${profile.streakDays} jours',
                  icon: Icons.local_fire_department,
                  color: Colors.deepOrange),
              const SizedBox(width: 12),
              _StatCard(
                  label: 'Niveau',
                  value: '${profile.level}',
                  icon: Icons.star,
                  color: Colors.amber.shade700),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
              label: 'Points totaux',
              value: '${profile.points} pts (niveau actuel)',
              icon: Icons.bolt,
              color: Colors.deepPurpleAccent,
              fullWidth: true),
          const SizedBox(height: 28),
          const Text('Badges débloqués',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: profile.badges.isEmpty
                ? Center(
                    child: Text(
                      'Pas encore de badge.\nComplète ton action du jour pour en débloquer !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: profile.badges.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: const Icon(Icons.emoji_events,
                          color: Colors.amber),
                      title: Text(profile.badges[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
        ],
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: card) : Expanded(child: card);
  }
}
