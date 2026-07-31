import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';
import '../services/avatar_service.dart';
import '../services/tr.dart';
import '../widgets/avatar_widget.dart';
import 'avatar_creator_screen.dart';
import 'settings_screen.dart';

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

    const denseField = InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('yourProfile'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                tooltip: context.tr('settings'),
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                AvatarWidget(config: avatarConfig, size: 110, animate: false),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AvatarCreatorScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.face_retouching_natural, size: 18),
                  label: Text(context.tr('customizeMyCoach')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: denseField.copyWith(labelText: context.tr('nameLabel')),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _goalController,
            maxLines: 2,
            decoration: denseField.copyWith(labelText: context.tr('goalLabel')),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () async {
              await pointsService.updateName(_nameController.text.trim());
              await pointsService.updateGoal(_goalController.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('profileUpdated'))),
                );
              }
            },
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(context.tr('save')),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
