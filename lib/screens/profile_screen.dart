import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/points_service.dart';
import '../services/avatar_service.dart';
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
          const Text('Ton profil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                  label: const Text('Personnaliser mon coach'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Prénom / pseudo'),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          const Text('Ton objectif'),
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
                  const SnackBar(content: Text('Profil mis à jour ✅')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
