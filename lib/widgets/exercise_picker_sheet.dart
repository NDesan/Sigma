import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise_library.dart';
import '../models/workout.dart';
import '../services/workout_service.dart';
import '../services/tr.dart';

class ExercisePickerSheet extends StatefulWidget {
  final ValueChanged<String> onSelect;

  const ExercisePickerSheet({super.key, required this.onSelect});

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  MuscleGroup? _selectedGroup;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LibraryExercise> get _filtered {
    final q = _query.trim().toLowerCase();
    return exerciseLibrary.where((ex) {
      final matchesGroup = _selectedGroup == null || ex.group == _selectedGroup;
      final matchesQuery = q.isEmpty || ex.name.toLowerCase().contains(q);
      return matchesGroup && matchesQuery;
    }).toList();
  }

  bool get _hasExactMatch {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return exerciseLibrary.any((ex) => ex.name.toLowerCase() == q);
  }

  void _select(String name) {
    Navigator.of(context).pop();
    widget.onSelect(name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
              child: Row(
                children: [
                  Text(
                    context.tr('addExercise'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: context.tr('searchExercises'),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.grey, size: 20),
                  filled: true,
                  fillColor: Colors.black26,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(
                    label: context.tr('all'),
                    selected: _selectedGroup == null,
                    onTap: () => setState(() => _selectedGroup = null),
                  ),
                  for (final group in MuscleGroup.values) ...[
                    const SizedBox(width: 6),
                    _CategoryChip(
                      label: context.tr(group.trKey),
                      selected: _selectedGroup == group,
                      onTap: () => setState(() => _selectedGroup = group),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        context.tr('noResults'),
                        style: const TextStyle(color: Colors.white38),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        if (_query.trim().isNotEmpty && !_hasExactMatch)
                          _CustomExerciseTile(
                            name: _query.trim(),
                            onTap: () => _select(_query.trim()),
                          ),
                        ..._filtered.map((ex) => _ExerciseTile(
                              exercise: ex,
                              onTap: () => _select(ex.name),
                            )),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurpleAccent : Colors.black26,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CustomExerciseTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _CustomExerciseTile({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.add_circle_outline,
          color: Colors.deepPurpleAccent),
      title: Text(
        '${context.tr('customExerciseName')}: $name',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      onTap: onTap,
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final LibraryExercise exercise;
  final VoidCallback onTap;

  const _ExerciseTile({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final workoutService = context.read<WorkoutService>();
    final previous = workoutService.getLastExerciseEntry(exercise.name);

    return ListTile(
      dense: true,
      leading: Icon(
        exercise.isBodyweight
            ? Icons.self_improvement
            : Icons.fitness_center,
        color: Colors.deepPurpleAccent,
        size: 20,
      ),
      title: Text(
        exercise.name,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      trailing: previous != null
          ? _PreviousBadge(previous: previous)
          : null,
      onTap: onTap,
    );
  }
}

class _PreviousBadge extends StatelessWidget {
  final ExerciseEntry previous;

  const _PreviousBadge({required this.previous});

  @override
  Widget build(BuildContext context) {
    final top = previous.sets.isNotEmpty
        ? previous.sets.reduce((a, b) => a.weightKg > b.weightKg ? a : b)
        : null;
    if (top == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${context.tr('prev')} ${top.weightKg.toStringAsFixed(1)}kg × ${top.reps}',
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
