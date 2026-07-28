import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/workout.dart';

/// Service generating responses for the Harsh AI Coach.
class AiCoachService {
  final bool useRemoteApi;
  final String? apiUrl;
  final String? apiKey;

  AiCoachService({
    this.useRemoteApi = false,
    this.apiUrl,
    this.apiKey,
  });

  final _rand = Random();

  final List<String> _harshGreetings = [
    "Oh, you finally opened the app? I thought you retired, {name}.",
    "Back again, {name}? Let's see if you actually work today or just pretend.",
    "Look who decided to show up. Ready to stop slacking, {name}?",
  ];

  final List<String> _missedDayRoasts = [
    "Skipped yesterday? Your couch must be thrilled. Your muscles aren't.",
    "A day without working out? Hope that extra rest was worth wasting your gains.",
    "Zero effort yesterday. Don't expect zero judgment today.",
    "Consistency is key, and right now, you're unlocking nothing.",
  ];

  final List<String> _improvedRoasts = [
    "You actually beat your previous numbers on {exercise}? Good. That's the absolute minimum I expect.",
    "Higher volume on {exercise} (+{percent}%). Don't get arrogant now; do it again next time.",
    "Finally, progress on {exercise}! You increased weight by {weight}kg. Keep this energy or don't bother.",
    "Alright, respectable performance on {exercise}. You earned a slight nod of approval.",
  ];

  final List<String> _regressedRoasts = [
    "Is this a joke? You dropped performance on {exercise} by {percent}%! What happened?",
    "Fewer reps and less weight on {exercise}? Are we going backward now?",
    "Pathetic effort on {exercise}. You did worse than your last workout. Step it up!",
    "Lower numbers on {exercise}. Did you forget how to push yourself or are you just giving up?",
  ];

  final List<String> _stagnantRoasts = [
    "Same exact weight and reps on {exercise}. Stagnation is just polite failure.",
    "Zero progress on {exercise}. You're literally just maintaining mediocrity.",
    "Identical stats on {exercise} as last time. If you aren't pushing forward, you're slipping back.",
  ];

  final List<String> _firstTimeRoasts = [
    "First time logging {exercise}? Great, now we have a benchmark. Next time better beat this.",
    "Logged {exercise}. Baseline set. Now let's see if you have the discipline to exceed it.",
  ];

  String greeting(UserProfile profile, {int daysInactive = 0}) {
    if (daysInactive >= 2) {
      final roast = _missedDayRoasts[_rand.nextInt(_missedDayRoasts.length)];
      return "🚨 INACTIVITY ALERT 🚨\n$roast";
    }
    final template = _harshGreetings[_rand.nextInt(_harshGreetings.length)];
    return template.replaceAll('{name}', profile.name);
  }

  /// Generate harsh evaluation for exercise comparison
  String generateWorkoutFeedback(List<ExerciseComparisonResult> results) {
    if (results.isEmpty) return "You submitted an empty workout? Wow, impressive laziness.";

    final sb = StringBuffer();

    int improvedCount = 0;
    int regressedCount = 0;

    for (final result in results) {
      final name = result.exerciseName;
      final percentStr = result.volumeDeltaPercent.abs().toStringAsFixed(1);
      final weightStr = result.weightDeltaKg.abs().toStringAsFixed(1);

      switch (result.status) {
        case PerformanceStatus.improved:
          improvedCount++;
          final template = _improvedRoasts[_rand.nextInt(_improvedRoasts.length)];
          sb.writeln(template
              .replaceAll('{exercise}', name)
              .replaceAll('{percent}', percentStr)
              .replaceAll('{weight}', weightStr));
          break;
        case PerformanceStatus.regressed:
          regressedCount++;
          final template = _regressedRoasts[_rand.nextInt(_regressedRoasts.length)];
          sb.writeln(template
              .replaceAll('{exercise}', name)
              .replaceAll('{percent}', percentStr)
              .replaceAll('{weight}', weightStr));
          break;
        case PerformanceStatus.stagnant:
          final template = _stagnantRoasts[_rand.nextInt(_stagnantRoasts.length)];
          sb.writeln(template.replaceAll('{exercise}', name));
          break;
        case PerformanceStatus.firstTime:
          final template = _firstTimeRoasts[_rand.nextInt(_firstTimeRoasts.length)];
          sb.writeln(template.replaceAll('{exercise}', name));
          break;
      }
    }

    sb.writeln();

    if (regressedCount > improvedCount) {
      sb.write("OVERALL SUMMARY: Total disappointing workout. Fix your sleep, eat right, and hit it harder next time.");
    } else if (improvedCount > 0) {
      sb.write("OVERALL SUMMARY: Acceptable session. Now go recover so you don't regress tomorrow.");
    } else {
      sb.write("OVERALL SUMMARY: Average at best. You're capable of more if you actually try.");
    }

    return sb.toString();
  }

  /// Interactive Coach Chat Response
  Future<String> respond(String userMessage, UserProfile profile) async {
    if (useRemoteApi && apiUrl != null) {
      try {
        return await _respondViaApi(userMessage, profile);
      } catch (_) {
        return _localResponse(userMessage, profile);
      }
    }
    return _localResponse(userMessage, profile);
  }

  String _localResponse(String userMessage, UserProfile profile) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('fatigue') || msg.contains('dur') || msg.contains('tired') || msg.contains('hard')) {
      return "Tired? Excuses don't burn calories or lift iron. Either do a light session or stop complaining.";
    }
    if (msg.contains('merci') || msg.contains('thanks')) {
      return "Don't thank me. Thank your future self if you actually stay consistent.";
    }
    if (msg.contains('skip') || msg.contains('miss')) {
      return "Skipping today? Fine, but don't cry to me when your stats drop tomorrow.";
    }

    return "Less talking, more lifting. Go log your sets and show me numbers!";
  }

  Future<String> _respondViaApi(String userMessage, UserProfile profile) async {
    final response = await http.post(
      Uri.parse(apiUrl!),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey != null) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a brutally honest, harsh, demanding, but effective AI Fitness Coach. '
                'User: ${profile.name}, Goal: ${profile.goal}. '
                'Be blunt, call out weak excuses, but demand excellence. Do not use corporate fluffy language.'
          },
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? _localResponse(userMessage, profile);
    }
    throw Exception('API error: ${response.statusCode}');
  }
}
