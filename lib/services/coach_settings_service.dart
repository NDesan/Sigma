import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CoachPersonality { gentle, balanced, aggressive, brutal }

class CoachSettingsService extends ChangeNotifier {
  static const _aggressivenessKey = 'coach_aggressiveness';

  double _aggressiveness = 0.6;
  double get aggressiveness => _aggressiveness;

  CoachPersonality get personality {
    if (_aggressiveness < 0.25) return CoachPersonality.gentle;
    if (_aggressiveness < 0.5) return CoachPersonality.balanced;
    if (_aggressiveness < 0.75) return CoachPersonality.aggressive;
    return CoachPersonality.brutal;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_aggressivenessKey);
    if (saved != null) {
      _aggressiveness = saved;
    }
    notifyListeners();
  }

  Future<void> setAggressiveness(double value) async {
    _aggressiveness = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_aggressivenessKey, _aggressiveness);
    notifyListeners();
  }
}
