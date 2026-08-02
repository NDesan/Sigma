import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../services/ai_coach_service.dart';
import '../widgets/coach_reaction_dialog.dart';
import '../widgets/rest_timer_sheet.dart';
import '../widgets/exercise_picker_sheet.dart';
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
          previousEntry: workoutService.getLastExerciseEntry(entry.exerciseName),
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

  void _addExercise(String name, {ExerciseEntry? previous}) {
    setState(() {
      final previousSets = previous?.sets ?? const <WorkoutSet>[];
      final sets = previousSets.isEmpty
          ? [
              _SetDraft(
                weightController: TextEditingController(),
                repsController: TextEditingController(),
                notesController: TextEditingController(),
              ),
            ]
          : previousSets
              .map((s) => _SetDraft(
                    weightController:
                        TextEditingController(text: s.weightKg.toString()),
                    repsController:
                        TextEditingController(text: s.reps.toString()),
                    notesController: TextEditingController(),
                  ))
              .toList();
      _exercises.add(_ExerciseDraft(
        nameController: TextEditingController(text: name),
        sets: sets,
        previousEntry: previous,
      ));
    });
    _saveDraft();
  }

  void _addQuickExercise(String name) {
    final workoutService = context.read<WorkoutService>();
    final previous = workoutService.getLastExerciseEntry(name);
    _addExercise(name, previous: previous);
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ExercisePickerSheet(
        onSelect: (name) {
          final workoutService = context.read<WorkoutService>();
          final previous = workoutService.getLastExerciseEntry(name);
          _addExercise(name, previous: previous);
        },
      ),
    );
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

  void _showRestTimer({bool autoStart = false, int duration = 60}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => RestTimerSheet(
        initialDuration: duration,
        autoStart: autoStart,
      ),
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

    final workoutService = context.read<WorkoutService>();
    await _saveMetadata();
    final endTime = _endDateTime ?? DateTime.now();

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
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showExercisePicker,
                  icon: const Icon(Icons.add),
                  label: Text(
                    context.tr('addExercise'),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.deepPurpleAccent,
                    side: const BorderSide(color: Colors.deepPurpleAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
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
            if (ex.previousEntry != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.history,
                        color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.tr('lastSessionHint', [
                          '${ex.previousEntry!.sets.length}',
                          ex.previousEntry!.maxWeight.toStringAsFixed(1),
                        ]),
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    final prevSet = ex.previousEntry != null &&
            setIndex < ex.previousEntry!.sets.length
        ? ex.previousEntry!.sets[setIndex]
        : null;

    final weight = double.tryParse(setDraft.weightController.text) ?? 0.0;
    final reps = int.tryParse(setDraft.repsController.text) ?? 0;
    final volume = weight * reps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Dismissible(
          key: ValueKey('set-${setDraft.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() {
              ex.sets.removeAt(setIndex);
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    context.tr('setPrefix', [(setIndex + 1).toString()]),
                    style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                _StepperInput(
                  controller: setDraft.weightController,
                  step: 2.5,
                  decimals: 1,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(width: 6),
                _StepperInput(
                  controller: setDraft.repsController,
                  step: 1,
                  decimals: 0,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(
                    volume > 0
                        ? '${volume.toStringAsFixed(0)}${context.tr('kg')}'
                        : '-',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.timer_outlined,
                      color: Colors.deepPurpleAccent, size: 20),
                  tooltip: context.tr('restTimer'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showRestTimer(autoStart: true),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() {
                      ex.sets.removeAt(setIndex);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        if (prevSet != null)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 2),
            child: Text(
              '${context.tr('prev')} ${prevSet.weightKg.toStringAsFixed(1)}${context.tr('kg')} × ${prevSet.reps}',
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 40, top: 4),
          child: TextField(
            controller: setDraft.notesController,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(
              hintText: context.tr('notes'),
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
              filled: true,
              fillColor: Colors.black26,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _StepperInput extends StatelessWidget {
  final TextEditingController controller;
  final double step;
  final int decimals;
  final ValueChanged<String> onChanged;

  const _StepperInput({
    required this.controller,
    required this.step,
    required this.decimals,
    required this.onChanged,
  });

  void _adjust(double delta) {
    final raw = controller.text.trim().replaceAll(',', '.');
    final current = double.tryParse(raw) ?? 0.0;
    var next = current + delta;
    if (decimals == 0) {
      next = next.roundToDouble();
    }
    next = math.max(0.0, next);
    final text = decimals == 0
        ? next.round().toString()
        : next.toStringAsFixed(decimals);
    controller.text = text;
    onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          onPressed: () => _adjust(-step),
        ),
        SizedBox(
          width: 46,
          child: TextField(
            controller: controller,
            keyboardType: decimals == 0
                ? TextInputType.number
                : const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none),
            ),
            onChanged: (_) => onChanged(controller.text),
          ),
        ),
        _StepButton(
          icon: Icons.add,
          onPressed: () => _adjust(step),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _StepButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.deepPurpleAccent, size: 16),
      ),
    );
  }
}

class _ExerciseDraft {
  final TextEditingController nameController;
  final List<_SetDraft> sets;
  final ExerciseEntry? previousEntry;

  _ExerciseDraft({
    required this.nameController,
    required this.sets,
    this.previousEntry,
  });
}

class _SetDraft {
  final TextEditingController weightController;
  final TextEditingController repsController;
  final TextEditingController notesController;
  final int id;

  _SetDraft({
    required this.weightController,
    required this.repsController,
    required this.notesController,
  }) : id = _setIdCounter++;
}

int _setIdCounter = 0;
