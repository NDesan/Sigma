import 'package:flutter/material.dart';

enum AvatarMood { happy, neutral, sleepy, cheering }

/// Avatar du coach : pour l'instant une forme stylisée animée en pur Flutter
/// (pas besoin d'assets externes). Tu pourras remplacer le contenu par un
/// Lottie animé (package déjà ajouté dans pubspec.yaml) une fois que tu as
/// un design d'avatar.
class AvatarWidget extends StatefulWidget {
  final AvatarMood mood;
  final double size;

  const AvatarWidget({
    super.key,
    this.mood = AvatarMood.neutral,
    this.size = 140,
  });

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bodyColor {
    switch (widget.mood) {
      case AvatarMood.happy:
        return Colors.orangeAccent;
      case AvatarMood.cheering:
        return Colors.greenAccent.shade400;
      case AvatarMood.sleepy:
        return Colors.blueGrey.shade300;
      case AvatarMood.neutral:
        return Colors.deepPurpleAccent;
    }
  }

  String get _face {
    switch (widget.mood) {
      case AvatarMood.happy:
        return '˘ ᵕ ˘';
      case AvatarMood.cheering:
        return '★ ᴥ ★';
      case AvatarMood.sleepy:
        return '- . -';
      case AvatarMood.neutral:
        return '• ᴗ •';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _bodyColor,
          boxShadow: [
            BoxShadow(
              color: _bodyColor.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          _face,
          style: TextStyle(
            fontSize: widget.size * 0.18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
