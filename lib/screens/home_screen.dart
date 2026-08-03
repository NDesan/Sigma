import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';
import '../services/avatar_service.dart';
import '../services/notification_service.dart';
import '../services/workout_service.dart';
import '../services/ai_coach_service.dart';
import '../services/tr.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/points_bar.dart';
import '../widgets/speech_bubble.dart';
import 'chat_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'workout_log_screen.dart';
import 'history_screen.dart';

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
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: context.tr('home')),
          NavigationDestination(
              icon: const Icon(Icons.chat_bubble_outline), label: context.tr('chat')),
          NavigationDestination(
              icon: const Icon(Icons.bar_chart), label: context.tr('history')),
          NavigationDestination(
              icon: const Icon(Icons.person_outline), label: context.tr('profile')),
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
    final avatarConfig = context.watch<AvatarService>().config;
    final workoutService = context.watch<WorkoutService>();
    final aiCoachService = context.read<AiCoachService>();
    final profile = pointsService.profile;

    final daysInactive = workoutService.daysSinceLastWorkout;
    final coachGreeting = aiCoachService.greeting(profile, daysInactive: daysInactive);

    final mood = daysInactive >= 2
        ? AvatarMood.sleepy
        : profile.streakDays >= 3
            ? AvatarMood.cheering
            : AvatarMood.happy;

    // Speech bubble colours change based on mood
    final Color bubbleBg;
    final Color bubbleBorder;
    final Color bubbleText;

    if (daysInactive >= 2) {
      bubbleBg = const Color(0xFF2C1418);
      bubbleBorder = Colors.redAccent.withOpacity(0.6);
      bubbleText = const Color(0xFFFF8A80);
    } else if (mood == AvatarMood.cheering) {
      bubbleBg = const Color(0xFF142C1A);
      bubbleBorder = Colors.greenAccent.withOpacity(0.5);
      bubbleText = const Color(0xFFB9F6CA);
    } else {
      bubbleBg = const Color(0xFF1E1E2C);
      bubbleBorder = Colors.deepPurpleAccent.withOpacity(0.4);
      bubbleText = Colors.white;
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PointsBar(profile: profile),
                const SizedBox(height: 24),

                // Speech bubble coming out of the coach
                SpeechBubble(
                  text: coachGreeting,
                  backgroundColor: bubbleBg,
                  borderColor: bubbleBorder,
                  textColor: bubbleText,
                ),

                // Avatar — tail of the speech bubble points toward it
                AvatarWidget(config: avatarConfig, mood: mood, size: 180),
                const SizedBox(height: 24),

                // LOG WORKOUT PRIMARY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => WorkoutLogScreen(aiCoachService: aiCoachService),
                        ),
                      );
                    },
                    icon: Icon(
                      workoutService.hasActiveSession
                          ? Icons.play_arrow_rounded
                          : Icons.fitness_center_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      workoutService.hasActiveSession
                          ? context.tr('resumeWorkout')
                          : context.tr('logWorkoutBtn'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: workoutService.hasActiveSession
                          ? Colors.orange
                          : Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Secondary Quick Check-in Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await pointsService.addPoints(10, badge: 'Quick Check-in');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('quickCheckin') + " (+10 ${context.tr('pts')})"),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(context.tr('quickCheckin')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      await notificationService.scheduleDailyReminder(
                        hour: 18,
                        minute: 0,
                        title: context.tr('notificationTitle'),
                        body: context.tr('notificationBody'),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('reminderScheduled')),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(context.tr('enableReminder')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

