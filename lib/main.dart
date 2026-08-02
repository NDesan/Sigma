import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/points_service.dart';
import 'services/avatar_service.dart';
import 'services/notification_service.dart';
import 'services/translation_service.dart';
import 'services/coach_settings_service.dart';
import 'screens/home_screen.dart';

import 'services/workout_service.dart';
import 'services/ai_coach_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final translationService = TranslationService();
  await translationService.load();

  final notificationService = NotificationService();
  await notificationService.init();

  final pointsService = PointsService();
  await pointsService.load();

  final avatarService = AvatarService();
  await avatarService.load();

  final workoutService = WorkoutService();
  await workoutService.load();

  final aiCoachService = AiCoachService(
    useRemoteApi: true,
    apiUrl: 'https://api.mistral.ai/v1/chat/completions',
    apiKey: dotenv.env['MISTRAL_API_KEY'] ?? '',
  );

  final coachSettingsService = CoachSettingsService();
  await coachSettingsService.load();

  runApp(CoachApp(
    translationService: translationService,
    pointsService: pointsService,
    avatarService: avatarService,
    workoutService: workoutService,
    aiCoachService: aiCoachService,
    notificationService: notificationService,
    coachSettingsService: coachSettingsService,
  ));
}

class CoachApp extends StatelessWidget {
  final TranslationService translationService;
  final PointsService pointsService;
  final AvatarService avatarService;
  final WorkoutService workoutService;
  final AiCoachService aiCoachService;
  final NotificationService notificationService;
  final CoachSettingsService coachSettingsService;

  const CoachApp({
    super.key,
    required this.translationService,
    required this.pointsService,
    required this.avatarService,
    required this.workoutService,
    required this.aiCoachService,
    required this.notificationService,
    required this.coachSettingsService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: translationService),
        ChangeNotifierProvider.value(value: pointsService),
        ChangeNotifierProvider.value(value: avatarService),
        ChangeNotifierProvider.value(value: workoutService),
        ChangeNotifierProvider.value(value: coachSettingsService),
        Provider.value(value: aiCoachService),
      ],
      child: Consumer<TranslationService>(
        builder: (context, ts, _) => MaterialApp(
          title: 'Sigma',
          debugShowCheckedModeBanner: false,
          locale: ts.locale,
          supportedLocales: TranslationService.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurpleAccent,
          ),
          home: HomeScreen(notificationService: notificationService),
        ),
      ),
    );
  }
}
