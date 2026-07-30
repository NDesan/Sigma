class WorkoutSet {
  final double weightKg;
  final int reps;
  final String? notes;

  WorkoutSet({
    required this.weightKg,
    required this.reps,
    this.notes,
  });

  double get totalVolume => weightKg * reps;

  Map<String, dynamic> toJson() => {
        'weightKg': weightKg,
        'reps': reps,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
        weightKg: (json['weightKg'] as num).toDouble(),
        reps: json['reps'] as int,
        notes: json['notes'] as String?,
      );

  WorkoutSet copyWith({double? weightKg, int? reps, String? notes}) =>
      WorkoutSet(
        weightKg: weightKg ?? this.weightKg,
        reps: reps ?? this.reps,
        notes: notes ?? this.notes,
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

  ExerciseEntry copyWith({String? exerciseName, List<WorkoutSet>? sets}) =>
      ExerciseEntry(
        exerciseName: exerciseName ?? this.exerciseName,
        sets: sets ?? this.sets,
      );
}

class WorkoutSession {
  final String id;
  final DateTime dateTime;
  final DateTime? endTime;
  final List<ExerciseEntry> exercises;
  final String? name;

  WorkoutSession({
    required this.id,
    required this.dateTime,
    this.endTime,
    required this.exercises,
    this.name,
  });

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(dateTime);
  }

  double get totalVolume =>
      exercises.fold(0, (sum, ex) => sum + ex.totalVolume);

  WorkoutSession copyWith({
    String? id,
    DateTime? dateTime,
    DateTime? endTime,
    List<ExerciseEntry>? exercises,
    String? name,
  }) =>
      WorkoutSession(
        id: id ?? this.id,
        dateTime: dateTime ?? this.dateTime,
        endTime: endTime ?? this.endTime,
        exercises: exercises ?? this.exercises,
        name: name ?? this.name,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        if (name != null && name!.isNotEmpty) 'name': name,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        exercises: (json['exercises'] as List)
            .map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        name: json['name'] as String?,
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
