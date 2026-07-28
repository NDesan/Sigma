import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';

class WorkoutService extends ChangeNotifier {
  static const String _storageKey = 'workout_sessions_v1';

  List<WorkoutSession> _sessions = [];
  bool _isLoaded = false;

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        _sessions = list
            .map((item) => WorkoutSession.fromJson(item as Map<String, dynamic>))
            .toList();
        _sessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      } catch (e) {
        debugPrint('Error loading workouts: $e');
        _sessions = [];
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  /// Get the most recent exercise entry for a given exercise name before a specified session date
  ExerciseEntry? getLastExerciseEntry(String exerciseName, {DateTime? beforeDate}) {
    final filterDate = beforeDate ?? DateTime.now();
    for (final session in _sessions) {
      if (session.dateTime.isBefore(filterDate)) {
        for (final entry in session.exercises) {
          if (entry.exerciseName.trim().toLowerCase() == exerciseName.trim().toLowerCase()) {
            return entry;
          }
        }
      }
    }
    return null;
  }

  /// Compare an exercise entry to its previous instance
  ExerciseComparisonResult compareExercise(ExerciseEntry current, {DateTime? beforeDate}) {
    final previous = getLastExerciseEntry(current.exerciseName, beforeDate: beforeDate);

    if (previous == null || previous.sets.isEmpty) {
      return ExerciseComparisonResult(
        exerciseName: current.exerciseName,
        status: PerformanceStatus.firstTime,
        volumeDeltaPercent: 0,
        weightDeltaKg: 0,
        current: current,
        previous: null,
      );
    }

    final currentVol = current.totalVolume;
    final prevVol = previous.totalVolume;

    final currentMaxWeight = current.maxWeight;
    final prevMaxWeight = previous.maxWeight;

    final weightDelta = currentMaxWeight - prevMaxWeight;
    final volumeDeltaPercent = prevVol > 0 ? ((currentVol - prevVol) / prevVol) * 100 : 0.0;

    PerformanceStatus status;
    // Difference higher than +2% volume or +0.5kg max weight is considered improved
    if (volumeDeltaPercent > 2.0 || weightDelta > 0.5) {
      status = PerformanceStatus.improved;
    } else if (volumeDeltaPercent < -2.0 || weightDelta < -0.5) {
      status = PerformanceStatus.regressed;
    } else {
      status = PerformanceStatus.stagnant;
    }

    return ExerciseComparisonResult(
      exerciseName: current.exerciseName,
      status: status,
      volumeDeltaPercent: volumeDeltaPercent,
      weightDeltaKg: weightDelta,
      current: current,
      previous: previous,
    );
  }

  /// Save a new workout session and return comparison results for all exercises in the session
  Future<List<ExerciseComparisonResult>> saveSession(WorkoutSession session) async {
    // Generate comparison before adding session to history list
    final results = session.exercises.map((e) => compareExercise(e, beforeDate: session.dateTime)).toList();

    _sessions.insert(0, session);
    await _save();
    notifyListeners();

    return results;
  }

  /// Get days since last workout
  int get daysSinceLastWorkout {
    if (_sessions.isEmpty) return 999;
    final lastWorkoutDate = _sessions.first.dateTime;
    final now = DateTime.now();
    final difference = now.difference(lastWorkoutDate).inDays;
    return difference;
  }
}
