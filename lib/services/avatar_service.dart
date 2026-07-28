import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/avatar_config.dart';

/// Gère la configuration visuelle de l'avatar (persistée localement),
/// séparément des points/streaks.
class AvatarService extends ChangeNotifier {
  static const _storageKey = 'avatar_config';

  AvatarConfig config = AvatarConfig();
  bool isLoaded = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      config = AvatarConfig.fromJson(jsonDecode(raw));
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(config.toJson()));
  }

  /// Met à jour la config avatar avec une fonction de modification,
  /// puis sauvegarde et notifie l'UI.
  Future<void> update(void Function(AvatarConfig config) mutate) async {
    mutate(config);
    await _save();
    notifyListeners();
  }
}
