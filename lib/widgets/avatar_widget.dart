import 'package:flutter/material.dart';
import '../models/avatar_config.dart';
import 'mii_avatar_painter.dart';

export 'mii_avatar_painter.dart' show AvatarMood;

/// Affiche l'avatar personnalisé du coach (façon Mii), avec une légère
/// animation de respiration/rebond pour lui donner vie.
class AvatarWidget extends StatefulWidget {
  final AvatarConfig config;
  final AvatarMood mood;
  final double size;
  final bool animate;

  const AvatarWidget({
    super.key,
    required this.config,
    this.mood = AvatarMood.neutral,
    this.size = 140,
    this.animate = true,
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
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.animate) _controller.repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painterWidget = CustomPaint(
      size: Size(widget.size, widget.size * 1.15),
      painter: MiiAvatarPainter(config: widget.config, mood: widget.mood),
    );

    if (!widget.animate) return painterWidget;

    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(offset: Offset(0, _bounce.value), child: child);
      },
      child: painterWidget,
    );
  }
}
