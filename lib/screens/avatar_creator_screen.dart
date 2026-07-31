import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';

class AvatarCreatorScreen extends StatelessWidget {
  const AvatarCreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnalise ton coach'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: FluttermojiCircleAvatar(
                radius: 85,
              ),
            ),
          ),
          Expanded(
            child: FluttermojiCustomizer(
              autosave: true,
            ),
          ),
        ],
      ),
    );
  }
}
