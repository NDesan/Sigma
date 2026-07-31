import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';
import '../services/avatar_service.dart';
import '../services/translation_service.dart';
import '../services/tr.dart';
import '../widgets/avatar_widget.dart';
import 'avatar_creator_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<PointsService>().profile;
    _nameController = TextEditingController(text: profile.name);
    _goalController = TextEditingController(text: profile.goal);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pointsService = context.watch<PointsService>();
    final avatarConfig = context.watch<AvatarService>().config;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('yourProfile'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                AvatarWidget(config: avatarConfig, size: 120, animate: false),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AvatarCreatorScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.face_retouching_natural),
                  label: Text(context.tr('customizeMyCoach')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(context.tr('nameLabel')),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          Text(context.tr('goalLabel')),
          const SizedBox(height: 6),
          TextField(
            controller: _goalController,
            maxLines: 2,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              await pointsService.updateName(_nameController.text.trim());
              await pointsService.updateGoal(_goalController.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('profileUpdated'))),
                );
              }
            },
            child: Text(context.tr('save')),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 8),
          Text(context.tr('language'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Consumer<TranslationService>(
            builder: (context, ts, _) => SegmentedButton<Locale>(
              segments: const [
                ButtonSegment(
                    value: Locale('fr'), label: Text('Français'), icon: Icon(Icons.language)),
                ButtonSegment(
                    value: Locale('en'), label: Text('English'), icon: Icon(Icons.language)),
              ],
              selected: {ts.locale},
              onSelectionChanged: (selected) {
                ts.setLocale(selected.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}
