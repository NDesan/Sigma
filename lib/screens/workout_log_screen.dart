import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../services/ai_coach_service.dart';
import '../widgets/coach_reaction_dialog.dart';
import '../widgets/rest_timer_sheet.dart';
import '../services/tr.dart';

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
  final TextEditingController _customExerciseController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

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

  DateTime _workoutDateTime = DateTime.now();
  DateTime? _endDateTime;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    _customExerciseController.dispose();
    _nameController.dispose();
    for (final ex in _exercises) {
      ex.nameController.dispose();
      for (final s in ex.sets) {
        s.weightController.dispose();
        s.repsController.dispose();
        s.notesController.dispose();
      }
    }
    super.dispose();
  }

  void _loadDraft() {
    final workoutService = context.read<WorkoutService>();
    if (workoutService.hasActiveSession) {
      final session = workoutService.activeSession!;
      _workoutDateTime = session.dateTime;
      _endDateTime = session.endTime;
      _nameController.text = session.name ?? '';
      for (final entry in session.exercises) {
        final exDraft = _ExerciseDraft(
          nameController: TextEditingController(text: entry.exerciseName),
          sets: entry.sets
              .map((set) => _SetDraft(
                    weightController:
                        TextEditingController(text: set.weightKg.toString()),
                    repsController:
                        TextEditingController(text: set.reps.toString()),
                    notesController:
                        TextEditingController(text: set.notes ?? ''),
                  ))
              .toList(),
        );
        _exercises.add(exDraft);
      }
    } else {
      workoutService.startNewSession();
      _workoutDateTime = workoutService.activeSession!.dateTime;
    }
  }

  Future<void> _saveMetadata() async {
    await context.read<WorkoutService>().updateActiveSessionMetadata(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      dateTime: _workoutDateTime,
      endTime: _endDateTime,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _workoutDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _workoutDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _workoutDateTime.hour,
          _workoutDateTime.minute,
        );
      });
      _saveMetadata();
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_workoutDateTime),
    );
    if (picked != null) {
      setState(() {
        _workoutDateTime = DateTime(
          _workoutDateTime.year,
          _workoutDateTime.month,
          _workoutDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
      _saveMetadata();
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endDateTime != null
          ? TimeOfDay.fromDateTime(_endDateTime!)
          : TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endDateTime = DateTime(
          _workoutDateTime.year,
          _workoutDateTime.month,
          _workoutDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
      _saveMetadata();
    }
  }

  Future<void> _saveDraft() async {
    final entries = _buildExerciseEntries();
    await context.read<WorkoutService>().updateActiveSessionExercises(entries);
  }

  String _exerciseKey(String name) {
    const map = {
      'Bench Press': 'benchPress',
      'Squat': 'squats',
      'Deadlift': 'deadlift',
      'Overhead Press': 'shoulderPress',
      'Pull Ups': 'pullUps',
      'Dumbbell Curl': 'bicepCurls',
      'Push Ups': 'pushUps',
      'Dips': 'tricepDips',
    };
    return map[name] ?? name;
  }

  List<ExerciseEntry> _buildExerciseEntries() {
    final entries = <ExerciseEntry>[];
    for (final draft in _exercises) {
      final name = draft.nameController.text.trim();
      if (name.isEmpty) continue;
      final sets = <WorkoutSet>[];
      for (final s in draft.sets) {
        final weight = double.tryParse(s.weightController.text) ?? 0.0;
        final reps = int.tryParse(s.repsController.text) ?? 0;
        if (reps > 0) {
          sets.add(WorkoutSet(
            weightKg: weight,
            reps: reps,
            notes: s.notesController.text.trim().isEmpty
                ? null
                : s.notesController.text.trim(),
          ));
        }
      }
      if (sets.isNotEmpty) {
        entries.add(ExerciseEntry(exerciseName: name, sets: sets));
      }
    }
    return entries;
  }

  void _addQuickExercise(String name) {
    setState(() {
      _exercises.add(_ExerciseDraft(
        nameController: TextEditingController(text: name),
        sets: [
          _SetDraft(
            weightController: TextEditingController(text: ''),
            repsController: TextEditingController(text: ''),
            notesController: TextEditingController(),
          ),
        ],
      ));
    });
  }

  void _addCustomExercise() {
    final name = _customExerciseController.text.trim();
    if (name.isEmpty) return;
    _addQuickExercise(name);
    _customExerciseController.clear();
  }

  void _addSet(_ExerciseDraft exercise) {
    setState(() {
      final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
      exercise.sets.add(_SetDraft(
        weightController:
            TextEditingController(text: lastSet?.weightController.text ?? ''),
        repsController:
            TextEditingController(text: lastSet?.repsController.text ?? ''),
        notesController: TextEditingController(),
      ));
    });
  }

  void _showRestTimer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const RestTimerSheet(),
    );
  }

  Future<void> _endWorkout() async {
    final entries = _buildExerciseEntries();
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                context.tr('addExerciseWarning'))),
      );
      return;
    }

    await _saveMetadata();
    final endTime = _endDateTime ?? DateTime.now();
    final workoutService = context.read<WorkoutService>();

    await _saveDraft();
    final session = await workoutService.endActiveSession(endTime: endTime);

    final comparisonResults = session.exercises
        .map((e) => workoutService.compareExercise(
            e, beforeDate: session.dateTime))
        .toList();
    final harshFeedback =
        widget.aiCoachService.generateWorkoutFeedback(comparisonResults);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CoachReactionDialog(
        comparisonResults: comparisonResults,
        coachFeedbackText: harshFeedback,
        onClose: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      context.tr('jan'), context.tr('feb'), context.tr('mar'), context.tr('apr'), context.tr('may'), context.tr('jun'),
      context.tr('jul'), context.tr('aug'), context.tr('sep'), context.tr('oct'), context.tr('nov'), context.tr('dec')
    ];
    final days = [
      context.tr('mon'), context.tr('tue'), context.tr('wed'), context.tr('thu'), context.tr('fri'), context.tr('sat'), context.tr('sun')
    ];
    final hour = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day} · $hour:$min $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _saveDraft();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF12121D),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nameController.text.trim().isEmpty
                    ? context.tr('workoutLog')
                    : _nameController.text.trim(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 18),
              ),
              Text(
                _formatDateTime(_workoutDateTime),
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.normal),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E2C),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.timer_outlined),
              tooltip: context.tr('restTimer'),
              onPressed: _showRestTimer,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWorkoutMetadataCard(),
              const SizedBox(height: 20),
              Text(
                context.tr('quickAddExercise'),
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
                    label: Text(context.tr(_exerciseKey(exName))),
                    backgroundColor: const Color(0xFF1E1E2C),
                    labelStyle: const TextStyle(
                        color: Colors.deepPurpleAccent, fontSize: 12),
                    onPressed: () => _addQuickExercise(exName),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customExerciseController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: context.tr('customExerciseName'),
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1E1E2C),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _addCustomExercise(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addCustomExercise,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                itemBuilder: (context, exIndex) {
                  final ex = _exercises[exIndex];
                  return _buildExerciseCard(ex, exIndex);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _endWorkout,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(
                    context.tr('endWorkout'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1.1),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutMetadataCard() {
    return Card(
      color: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              decoration: InputDecoration(
                hintText: context.tr('workoutName'),
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (_) {
                setState(() {});
                _saveMetadata();
              },
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: _formatDate(_workoutDateTime),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.schedule,
              label: '${context.tr('start')} ${_formatTime(_workoutDateTime)}',
              onTap: _pickStartTime,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.timer_outlined,
              label: _endDateTime != null
                  ? '${context.tr('end')} ${_formatTime(_endDateTime!)}'
                  : context.tr('endTimeNotSet'),
              onTap: _pickEndTime,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurpleAccent, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Spacer(),
            const Icon(Icons.edit, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      context.tr('jan'), context.tr('feb'), context.tr('mar'), context.tr('apr'), context.tr('may'), context.tr('jun'),
      context.tr('jul'), context.tr('aug'), context.tr('sep'), context.tr('oct'), context.tr('nov'), context.tr('dec')
    ];
    final days = [
      context.tr('mon'), context.tr('tue'), context.tr('wed'), context.tr('thu'), context.tr('fri'), context.tr('sat'), context.tr('sun')
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $amPm';
  }

  Widget _buildExerciseCard(_ExerciseDraft ex, int exIndex) {
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
                    decoration: InputDecoration(
                      hintText: context.tr('exerciseName'),
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      _exercises.removeAt(exIndex);
                    });
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(
                      width: 32,
                      child: Text(context.tr('sets'),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text(context.tr('kg'),
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text(context.tr('repsAbbr'),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 3,
                      child: Text(context.tr('notes'),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))),
                  SizedBox(width: 32),
                ],
              ),
            ),
            Column(
              children: List.generate(ex.sets.length, (setIndex) {
                final setDraft = ex.sets[setIndex];
                return _buildSetRow(ex, setDraft, setIndex);
              }),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _addSet(ex),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(context.tr('addSet')),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurpleAccent),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showRestTimer,
                  icon: const Icon(Icons.timer_outlined, size: 16),
                  label: Text(context.tr('restTimer')),
                  style:
                      TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(
      _ExerciseDraft ex, _SetDraft setDraft, int setIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              context.tr('setPrefix', [(setIndex + 1).toString()]),
              style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: setDraft.weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: TextField(
              controller: setDraft.repsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: TextField(
              controller: setDraft.notesController,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: context.tr('optional'),
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                filled: true,
                fillColor: Colors.black26,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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
  final TextEditingController notesController;

  _SetDraft({
    required this.weightController,
    required this.repsController,
    required this.notesController,
  });
}
