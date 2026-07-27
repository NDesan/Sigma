import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Gère les points, niveaux, et streaks (séries de jours actifs).
/// C'est le moteur "gamification" façon Duolingo.
class PointsService extends ChangeNotifier {
  static const _storageKey = 'user_profile';

  UserProfile profile = UserProfile();
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      profile = UserProfile.fromJson(jsonDecode(raw));
    }
    _loaded = true;
    _updateStreakOnOpen();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
  }

  /// Appelé au démarrage : vérifie si le streak continue, casse, ou augmente.
  void _updateStreakOnOpen() {
    final now = DateTime.now();
    final last = profile.lastActiveDate;

    if (last == null) {
      profile.streakDays = 0;
    } else {
      final daysDiff = _daysBetween(last, now);
      if (daysDiff == 0) {
        // déjà venu aujourd'hui, on ne touche pas au streak
      } else if (daysDiff == 1) {
        // jour consécutif -> le streak sera incrémenté lors de la prochaine action
      } else if (daysDiff > 1) {
        // streak cassé
        profile.streakDays = 0;
      }
    }
  }

  int _daysBetween(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }

  /// À appeler quand l'utilisateur complète une action (exercice, check-in, etc.)
  Future<void> addPoints(int amount, {String? badge}) async {
    final now = DateTime.now();
    final last = profile.lastActiveDate;

    if (last == null || _daysBetween(last, now) >= 1) {
      profile.streakDays += 1;
    }
    profile.lastActiveDate = now;
    profile.points += amount;

    // Passage de niveau
    while (profile.points >= profile.level * 100) {
      profile.points -= profile.level * 100;
      profile.level += 1;
    }

    if (badge != null && !profile.badges.contains(badge)) {
      profile.badges.add(badge);
    }

    await _save();
    notifyListeners();
  }

  Future<void> updateGoal(String goal) async {
    profile.goal = goal;
    await _save();
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    profile.name = name;
    await _save();
    notifyListeners();
  }
}
