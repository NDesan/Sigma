import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';
import '../models/avatar_config.dart';

export 'package:fluttermoji/fluttermoji.dart' show FluttermojiCircleAvatar;

enum AvatarMood { happy, neutral, sleepy, cheering, angry, thinking, exercising, talking }

class AvatarWidget extends StatelessWidget {
  final AvatarConfig? config;
  final AvatarMood mood;
  final double size;
  final bool animate;
  final bool talking;

  const AvatarWidget({
    super.key,
    this.config,
    this.mood = AvatarMood.neutral,
    this.size = 140,
    this.animate = true,
    this.talking = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: FluttermojiCircleAvatar(
        radius: size / 2,
      ),
    );
  }
}
