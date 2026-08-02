enum MuscleGroup {
  chest,
  back,
  legs,
  shoulders,
  arms,
  core,
  cardio;

  String get trKey => name;
}

class LibraryExercise {
  final String name;
  final MuscleGroup group;
  final bool isBodyweight;

  const LibraryExercise(this.name, this.group, {this.isBodyweight = false});
}

const List<LibraryExercise> exerciseLibrary = [
  // Chest
  LibraryExercise('Bench Press', MuscleGroup.chest),
  LibraryExercise('Incline Bench Press', MuscleGroup.chest),
  LibraryExercise('Dumbbell Bench Press', MuscleGroup.chest),
  LibraryExercise('Incline Dumbbell Press', MuscleGroup.chest),
  LibraryExercise('Chest Fly', MuscleGroup.chest),
  LibraryExercise('Cable Crossover', MuscleGroup.chest),
  LibraryExercise('Pec Deck', MuscleGroup.chest),
  LibraryExercise('Push Ups', MuscleGroup.chest, isBodyweight: true),
  LibraryExercise('Dips', MuscleGroup.chest, isBodyweight: true),

  // Back
  LibraryExercise('Deadlift', MuscleGroup.back),
  LibraryExercise('Barbell Row', MuscleGroup.back),
  LibraryExercise('One-Arm Dumbbell Row', MuscleGroup.back),
  LibraryExercise('Seated Cable Row', MuscleGroup.back),
  LibraryExercise('Lat Pulldown', MuscleGroup.back),
  LibraryExercise('T-Bar Row', MuscleGroup.back),
  LibraryExercise('Face Pull', MuscleGroup.back),
  LibraryExercise('Reverse Fly', MuscleGroup.back),
  LibraryExercise('Pull Ups', MuscleGroup.back, isBodyweight: true),
  LibraryExercise('Chin Ups', MuscleGroup.back, isBodyweight: true),

  // Legs
  LibraryExercise('Squat', MuscleGroup.legs),
  LibraryExercise('Front Squat', MuscleGroup.legs),
  LibraryExercise('Goblet Squat', MuscleGroup.legs),
  LibraryExercise('Romanian Deadlift', MuscleGroup.legs),
  LibraryExercise('Leg Press', MuscleGroup.legs),
  LibraryExercise('Lunges', MuscleGroup.legs),
  LibraryExercise('Bulgarian Split Squat', MuscleGroup.legs),
  LibraryExercise('Leg Extension', MuscleGroup.legs),
  LibraryExercise('Leg Curl', MuscleGroup.legs),
  LibraryExercise('Calf Raises', MuscleGroup.legs),
  LibraryExercise('Hip Thrust', MuscleGroup.legs),
  LibraryExercise('Glute Bridge', MuscleGroup.legs),

  // Shoulders
  LibraryExercise('Overhead Press', MuscleGroup.shoulders),
  LibraryExercise('Dumbbell Shoulder Press', MuscleGroup.shoulders),
  LibraryExercise('Arnold Press', MuscleGroup.shoulders),
  LibraryExercise('Lateral Raise', MuscleGroup.shoulders),
  LibraryExercise('Front Raise', MuscleGroup.shoulders),
  LibraryExercise('Rear Delt Fly', MuscleGroup.shoulders),
  LibraryExercise('Shrugs', MuscleGroup.shoulders),
  LibraryExercise('Upright Row', MuscleGroup.shoulders),

  // Arms
  LibraryExercise('Barbell Curl', MuscleGroup.arms),
  LibraryExercise('Dumbbell Curl', MuscleGroup.arms),
  LibraryExercise('Hammer Curl', MuscleGroup.arms),
  LibraryExercise('Preacher Curl', MuscleGroup.arms),
  LibraryExercise('Incline Curl', MuscleGroup.arms),
  LibraryExercise('Tricep Pushdown', MuscleGroup.arms),
  LibraryExercise('Skull Crusher', MuscleGroup.arms),
  LibraryExercise('Overhead Tricep Extension', MuscleGroup.arms),
  LibraryExercise('Close-Grip Bench', MuscleGroup.arms),
  LibraryExercise('Tricep Dips', MuscleGroup.arms, isBodyweight: true),

  // Core
  LibraryExercise('Plank', MuscleGroup.core, isBodyweight: true),
  LibraryExercise('Side Plank', MuscleGroup.core, isBodyweight: true),
  LibraryExercise('Crunches', MuscleGroup.core, isBodyweight: true),
  LibraryExercise('Bicycle Crunch', MuscleGroup.core, isBodyweight: true),
  LibraryExercise('Russian Twist', MuscleGroup.core),
  LibraryExercise('Hanging Leg Raise', MuscleGroup.core),
  LibraryExercise('Ab Wheel Rollout', MuscleGroup.core),
  LibraryExercise('Mountain Climbers', MuscleGroup.core, isBodyweight: true),

  // Cardio
  LibraryExercise('Running', MuscleGroup.cardio),
  LibraryExercise('Cycling', MuscleGroup.cardio),
  LibraryExercise('Rowing', MuscleGroup.cardio),
  LibraryExercise('Jump Rope', MuscleGroup.cardio),
  LibraryExercise('Stair Climber', MuscleGroup.cardio),
  LibraryExercise('Elliptical', MuscleGroup.cardio),
  LibraryExercise('Swimming', MuscleGroup.cardio),
  LibraryExercise('Walking', MuscleGroup.cardio),
  LibraryExercise('Burpees', MuscleGroup.cardio, isBodyweight: true),
  LibraryExercise('Jumping Jacks', MuscleGroup.cardio, isBodyweight: true),
];
