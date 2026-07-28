
class WorkoutSet {
  final double weightKg;
  final int reps;

  WorkoutSet({
    required this.weightKg,
    required this.reps,
  });

  double get totalVolume => weightKg * reps;

  Map<String, dynamic> toJson() => {
        'weightKg': weightKg,
        'reps': reps,
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        weightKg: (json['weightKg'] as num).toDouble(),
        reps: json['reps'] as int,
      );
}

class ExerciseEntry {
  final String exerciseName;
  final List<WorkoutSet> sets;

  ExerciseEntry({
    required this.exerciseName,
    required this.sets,
  });

  double get totalVolume =>
      sets.fold(0, (sum, set) => sum + set.totalVolume);

  double get maxWeight =>
      sets.isEmpty ? 0 : sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);

  int get totalReps => sets.fold(0, (sum, set) => sum + set.reps);

  Map<String, dynamic> toJson() => {
        'exerciseName': exerciseName,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) => ExerciseEntry(
        exerciseName: json['exerciseName'] as String,
        sets: (json['sets'] as List)
            .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class WorkoutSession {
  final String id;
  final DateTime dateTime;
  final List<ExerciseEntry> exercises;

  WorkoutSession({
    required this.id,
    required this.dateTime,
    required this.exercises,
  });

  double get totalVolume =>
      exercises.fold(0, (sum, ex) => sum + ex.totalVolume);

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        exercises: (json['exercises'] as List)
            .map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

enum PerformanceStatus {
  improved,
  stagnant,
  regressed,
  firstTime,
}

class ExerciseComparisonResult {
  final String exerciseName;
  final PerformanceStatus status;
  final double volumeDeltaPercent;
  final double weightDeltaKg;
  final ExerciseEntry current;
  final ExerciseEntry? previous;

  ExerciseComparisonResult({
    required this.exerciseName,
    required this.status,
    required this.volumeDeltaPercent,
    required this.weightDeltaKg,
    required this.current,
    this.previous,
  });
}
