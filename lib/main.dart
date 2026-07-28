import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/points_service.dart';
import 'services/avatar_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

import 'services/workout_service.dart';
import 'services/ai_coach_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();

  final pointsService = PointsService();
  await pointsService.load();

  final avatarService = AvatarService();
  await avatarService.load();

  final workoutService = WorkoutService();
  await workoutService.load();

  final aiCoachService = AiCoachService();

  runApp(CoachApp(
    pointsService: pointsService,
    avatarService: avatarService,
    workoutService: workoutService,
    aiCoachService: aiCoachService,
    notificationService: notificationService,
  ));
}

class CoachApp extends StatelessWidget {
  final PointsService pointsService;
  final AvatarService avatarService;
  final WorkoutService workoutService;
  final AiCoachService aiCoachService;
  final NotificationService notificationService;

  const CoachApp({
    super.key,
    required this.pointsService,
    required this.avatarService,
    required this.workoutService,
    required this.aiCoachService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: pointsService),
        ChangeNotifierProvider.value(value: avatarService),
        ChangeNotifierProvider.value(value: workoutService),
        Provider.value(value: aiCoachService),
      ],
      child: MaterialApp(
        title: 'Mon Coach',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurpleAccent,
          fontFamily: 'Roboto',
        ),
        home: HomeScreen(notificationService: notificationService),
      ),
    );
  }
}
