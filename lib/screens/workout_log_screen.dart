import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../services/ai_coach_service.dart';
import '../widgets/coach_reaction_dialog.dart';

class WorkoutLogScreen extends StatefulWidget {
  final AiCoachService aiCoachService;

  const WorkoutLogScreen({
    super.key,
    required this.aiCoachService,
  });

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  final List<_ExerciseDraft> _exercises = [];

  final List<String> _commonExercises = [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Overhead Press',
    'Pull Ups',
    'Dumbbell Curl',
    'Push Ups',
    'Dips',
  ];

  @override
  void initState() {
    super.initState();
    _addDefaultExercise();
  }

  void _addDefaultExercise() {
    setState(() {
      _exercises.add(_ExerciseDraft(
        nameController: TextEditingController(text: 'Bench Press'),
        sets: [
          _SetDraft(weightController: TextEditingController(text: '60'), repsController: TextEditingController(text: '10')),
          _SetDraft(weightController: TextEditingController(text: '60'), repsController: TextEditingController(text: '10')),
          _SetDraft(weightController: TextEditingController(text: '60'), repsController: TextEditingController(text: '8')),
        ],
      ));
    });
  }

  void _addNewExercise(String name) {
    setState(() {
      _exercises.add(_ExerciseDraft(
        nameController: TextEditingController(text: name),
        sets: [
          _SetDraft(weightController: TextEditingController(text: '50'), repsController: TextEditingController(text: '10')),
        ],
      ));
    });
  }

  Future<void> _submitWorkout() async {
    if (_exercises.isEmpty) return;

    final List<ExerciseEntry> exerciseEntries = [];

    for (final draft in _exercises) {
      final name = draft.nameController.text.trim();
      if (name.isEmpty) continue;

      final List<WorkoutSet> sets = [];
      for (final s in draft.sets) {
        final weight = double.tryParse(s.weightController.text) ?? 0.0;
        final reps = int.tryParse(s.repsController.text) ?? 0;
        if (reps > 0) {
          sets.add(WorkoutSet(weightKg: weight, reps: reps));
        }
      }

      if (sets.isNotEmpty) {
        exerciseEntries.add(ExerciseEntry(exerciseName: name, sets: sets));
      }
    }

    if (exerciseEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one valid set with reps > 0!")),
      );
      return;
    }

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      exercises: exerciseEntries,
    );

    final workoutService = Provider.of<WorkoutService>(context, listen: false);
    final comparisonResults = await workoutService.saveSession(session);
    final harshFeedback = widget.aiCoachService.generateWorkoutFeedback(comparisonResults);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CoachReactionDialog(
        comparisonResults: comparisonResults,
        coachFeedbackText: harshFeedback,
        onClose: () {
          Navigator.of(context).pop(); // Exit workout log screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121D),
      appBar: AppBar(
        title: const Text(
          "LOG WORKOUT",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: const Color(0xFF1E1E2C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Chips selection shortcut
            const Text(
              "QUICK ADD EXERCISE",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonExercises.map((exName) {
                return ActionChip(
                  label: Text(exName),
                  backgroundColor: const Color(0xFF1E1E2C),
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 12),
                  onPressed: () => _addNewExercise(exName),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Exercise Draft Cards List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exercises.length,
              itemBuilder: (context, exIndex) {
                final ex = _exercises[exIndex];
                return Card(
                  color: const Color(0xFF1E1E2C),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ex.nameController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Exercise Name",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _exercises.removeAt(exIndex);
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white10),

                        // Sets Header
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              SizedBox(width: 40, child: Text("SET", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(child: Text("KG", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(child: Text("REPS", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                              SizedBox(width: 40),
                            ],
                          ),
                        ),

                        // Sets list
                        Column(
                          children: List.generate(ex.sets.length, (setIndex) {
                            final setDraft = ex.sets[setIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      "#${setIndex + 1}",
                                      style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: setDraft.weightController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.black26,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: setDraft.repsController,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.black26,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          ex.sets.removeAt(setIndex);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),

                        // Add Set button
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              final lastSet = ex.sets.isNotEmpty ? ex.sets.last : null;
                              ex.sets.add(_SetDraft(
                                weightController: TextEditingController(text: lastSet?.weightController.text ?? '50'),
                                repsController: TextEditingController(text: lastSet?.repsController.text ?? '10'),
                              ));
                            });
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("ADD SET"),
                          style: TextButton.styleFrom(foregroundColor: Colors.deepPurpleAccent),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Submit Workout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitWorkout,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  "FINISH & GET COACH FEEDBACK",
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ExerciseDraft {
  final TextEditingController nameController;
  final List<_SetDraft> sets;

  _ExerciseDraft({
    required this.nameController,
    required this.sets,
  });
}

class _SetDraft {
  final TextEditingController weightController;
  final TextEditingController repsController;

  _SetDraft({
    required this.weightController,
    required this.repsController,
  });
}
