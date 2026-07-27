import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';
import '../services/notification_service.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/points_bar.dart';
import 'chat_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final NotificationService notificationService;

  const HomeScreen({super.key, required this.notificationService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _CoachHomeTab(notificationService: widget.notificationService),
      const ChatScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline), label: 'Coach'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Progrès'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

class _CoachHomeTab extends StatelessWidget {
  final NotificationService notificationService;

  const _CoachHomeTab({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    final pointsService = context.watch<PointsService>();
    final profile = pointsService.profile;

    final mood = profile.streakDays >= 3
        ? AvatarMood.cheering
        : profile.streakDays == 0
            ? AvatarMood.sleepy
            : AvatarMood.happy;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          PointsBar(profile: profile),
          const SizedBox(height: 30),
          Text(
            'Salut ${profile.name} 👋',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Objectif : ${profile.goal}',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          AvatarWidget(mood: mood, size: 180),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                await pointsService.addPoints(10, badge: 'Premier check-in');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('+10 points ! Ton coach est fier de toi 🎉')),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("J'ai fait mon action du jour"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await notificationService.scheduleDailyReminder(
                  hour: 18,
                  minute: 0,
                  title: 'Ton coach t\'attend 👀',
                  body: 'Petit check-in du jour ? 5 minutes suffisent.',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Rappel quotidien programmé à 18h00 ✅')),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Activer le rappel quotidien'),
            ),
          ),
        ],
      ),
    );
  }
}
