/// Représente l'état de progression de l'utilisateur :
/// points, niveau, streak (série de jours consécutifs), objectifs.
class UserProfile {
  String name;
  String goal;
  int points;
  int level;
  int streakDays;
  DateTime? lastActiveDate;
  List<String> badges;

  UserProfile({
    this.name = 'Toi',
    this.goal = 'Bouger un peu plus chaque jour',
    this.points = 0,
    this.level = 1,
    this.streakDays = 0,
    this.lastActiveDate,
    List<String>? badges,
  }) : badges = badges ?? [];

  /// Points nécessaires pour passer au niveau suivant.
  /// Courbe simple façon Duolingo : ça augmente à chaque niveau.
  int get pointsForNextLevel => level * 100;

  double get progressToNextLevel {
    final pointsInLevel = points % pointsForNextLevel;
    return pointsInLevel / pointsForNextLevel;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'goal': goal,
        'points': points,
        'level': level,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'badges': badges,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? 'Toi',
        goal: json['goal'] ?? 'Bouger un peu plus chaque jour',
        points: json['points'] ?? 0,
        level: json['level'] ?? 1,
        streakDays: json['streakDays'] ?? 0,
        lastActiveDate: json['lastActiveDate'] != null
            ? DateTime.parse(json['lastActiveDate'])
            : null,
        badges: List<String>.from(json['badges'] ?? []),
      );
}
