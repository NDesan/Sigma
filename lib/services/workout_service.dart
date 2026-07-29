import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';

class WorkoutService extends ChangeNotifier {
  static const String _storageKey = 'workout_sessions_v1';
  static const String _activeSessionKey = 'active_workout_session';

  List<WorkoutSession> _sessions = [];
  WorkoutSession? _activeSession;
  bool _isLoaded = false;

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);
  WorkoutSession? get activeSession => _activeSession;
  bool get hasActiveSession => _activeSession != null;
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

    final activeJson = prefs.getString(_activeSessionKey);
    if (activeJson != null && activeJson.isNotEmpty) {
      try {
        _activeSession =
            WorkoutSession.fromJson(jsonDecode(activeJson) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('Error loading active session: $e');
        _activeSession = null;
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<void> _saveActiveSessionDraft() async {
    if (_activeSession == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _activeSessionKey, jsonEncode(_activeSession!.toJson()));
  }

  Future<void> _clearActiveSessionDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeSessionKey);
  }

  void startNewSession() {
    _activeSession = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      exercises: [],
    );
    _saveActiveSessionDraft();
    notifyListeners();
  }

  Future<void> updateActiveSessionExercises(List<ExerciseEntry> exercises) async {
    if (_activeSession == null) return;
    _activeSession = WorkoutSession(
      id: _activeSession!.id,
      dateTime: _activeSession!.dateTime,
      exercises: exercises,
    );
    await _saveActiveSessionDraft();
    notifyListeners();
  }

  Future<WorkoutSession> endActiveSession({required DateTime endTime}) async {
    if (_activeSession == null) {
      throw StateError('No active session to end');
    }

    final completedSession = WorkoutSession(
      id: _activeSession!.id,
      dateTime: _activeSession!.dateTime,
      endTime: endTime,
      exercises: _activeSession!.exercises,
    );

    _sessions.insert(0, completedSession);
    await _saveSessions();

    _activeSession = null;
    await _clearActiveSessionDraft();
    notifyListeners();

    return completedSession;
  }

  void cancelActiveSession() {
    _activeSession = null;
    _clearActiveSessionDraft();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    await _saveSessions();
    notifyListeners();
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

  /// Save a new workout session and return comparison results for all exercises
  Future<List<ExerciseComparisonResult>> saveSession(WorkoutSession session) async {
    final results = session.exercises
        .map((e) => compareExercise(e, beforeDate: session.dateTime))
        .toList();

    _sessions.insert(0, session);
    await _saveSessions();
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
