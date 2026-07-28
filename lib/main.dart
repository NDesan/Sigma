import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/points_service.dart';
import 'services/avatar_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();

  final pointsService = PointsService();
  await pointsService.load();

  final avatarService = AvatarService();
  await avatarService.load();

  runApp(CoachApp(
    pointsService: pointsService,
    avatarService: avatarService,
    notificationService: notificationService,
  ));
}

class CoachApp extends StatelessWidget {
  final PointsService pointsService;
  final AvatarService avatarService;
  final NotificationService notificationService;

  const CoachApp({
    super.key,
    required this.pointsService,
    required this.avatarService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: pointsService),
        ChangeNotifierProvider.value(value: avatarService),
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
