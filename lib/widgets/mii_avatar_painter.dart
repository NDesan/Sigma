import 'package:flutter/material.dart';
import '../models/avatar_config.dart';

enum AvatarMood { happy, neutral, sleepy, cheering }

/// Dessine l'avatar en vectoriel pur (aucun asset requis), façon Mii :
/// tête + cheveux + yeux + bouche + accessoire, tout personnalisable.
class MiiAvatarPainter extends CustomPainter {
  final AvatarConfig config;
  final AvatarMood mood;

  MiiAvatarPainter({required this.config, required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final headRadius = w * 0.36;
    final headCenter = Offset(w / 2, h * 0.48);

    _paintShoulders(canvas, size);
    _paintNeck(canvas, headCenter, headRadius);
    _paintHairBack(canvas, headCenter, headRadius);
    _paintHead(canvas, headCenter, headRadius);
    _paintEyes(canvas, headCenter, headRadius);
    _paintMouth(canvas, headCenter, headRadius);
    _paintHairFront(canvas, headCenter, headRadius);
    _paintAccessory(canvas, headCenter, headRadius);
  }

  void _paintShoulders(Canvas canvas, Size size) {
    final paint = Paint()..color = config.outfitColor;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.85, size.height * 0.82)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 0.68,
        size.width * 0.15,
        size.height * 0.82,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintNeck(Canvas canvas, Offset headCenter, double r) {
    final paint = Paint()..color = config.skinTone;
    final rect = Rect.fromCenter(
      center: Offset(headCenter.dx, headCenter.dy + r * 0.85),
      width: r * 0.7,
      height: r * 0.6,
    );
    canvas.drawRect(rect, paint);
  }

  void _paintHead(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = config.skinTone;
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 1.7, height: r * 2),
      paint,
    );
  }

  void _paintEyes(Canvas canvas, Offset c, double r) {
    final eyeY = c.dy - r * 0.05;
    final dx = r * 0.42;
    final leftCenter = Offset(c.dx - dx, eyeY);
    final rightCenter = Offset(c.dx + dx, eyeY);

    final isSleepy = mood == AvatarMood.sleepy;
    final isCheering = mood == AvatarMood.cheering;

    for (final eyeCenter in [leftCenter, rightCenter]) {
      if (isSleepy || config.eyeStyle == EyeStyle.sleepyLids) {
        // yeux mi-clos : simple arc
        final paint = Paint()
          ..color = config.eyeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.06
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCenter(center: eyeCenter, width: r * 0.4, height: r * 0.25),
          0.15,
          2.8,
          false,
          paint,
        );
        continue;
      }

      double eyeWidth;
      double eyeHeight;
      switch (config.eyeStyle) {
        case EyeStyle.almond:
          eyeWidth = r * 0.32;
          eyeHeight = r * 0.18;
          break;
        case EyeStyle.big:
          eyeWidth = r * 0.4;
          eyeHeight = r * 0.4;
          break;
        case EyeStyle.round:
        case EyeStyle.sleepyLids:
          eyeWidth = r * 0.3;
          eyeHeight = r * 0.3;
          break;
      }

      if (isCheering) {
        eyeHeight *= 1.15;
        eyeWidth *= 1.1;
      }

      // blanc de l'oeil
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: eyeWidth, height: eyeHeight),
        whitePaint,
      );
      // iris/pupille
      final pupilPaint = Paint()..color = config.eyeColor;
      canvas.drawCircle(eyeCenter, eyeHeight * 0.32, pupilPaint);

      // petit reflet
      canvas.drawCircle(
        Offset(eyeCenter.dx + eyeHeight * 0.12, eyeCenter.dy - eyeHeight * 0.12),
        eyeHeight * 0.08,
        Paint()..color = Colors.white,
      );
    }
  }

  void _paintMouth(Canvas canvas, Offset c, double r) {
    final mouthCenter = Offset(c.dx, c.dy + r * 0.55);
    final paint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.07
      ..strokeCap = StrokeCap.round;

    var style = config.mouthStyle;
    if (mood == AvatarMood.cheering) style = MouthStyle.grin;
    if (mood == AvatarMood.sleepy) style = MouthStyle.small;

    switch (style) {
      case MouthStyle.smile:
        canvas.drawArc(
          Rect.fromCenter(center: mouthCenter, width: r * 0.55, height: r * 0.4),
          0.2,
          2.7,
          false,
          paint,
        );
        break;
      case MouthStyle.grin:
        final path = Path()
          ..moveTo(mouthCenter.dx - r * 0.3, mouthCenter.dy - r * 0.05)
          ..quadraticBezierTo(
            mouthCenter.dx,
            mouthCenter.dy + r * 0.35,
            mouthCenter.dx + r * 0.3,
            mouthCenter.dy - r * 0.05,
          )
          ..close();
        canvas.drawPath(path, Paint()..color = const Color(0xFF6D4C41));
        canvas.drawPath(
          Path()
            ..moveTo(mouthCenter.dx - r * 0.22, mouthCenter.dy + r * 0.02)
            ..quadraticBezierTo(
              mouthCenter.dx,
              mouthCenter.dy + r * 0.18,
              mouthCenter.dx + r * 0.22,
              mouthCenter.dy + r * 0.02,
            )
            ..close(),
          Paint()..color = Colors.white,
        );
        break;
      case MouthStyle.small:
        canvas.drawArc(
          Rect.fromCenter(center: mouthCenter, width: r * 0.25, height: r * 0.2),
          0.3,
          2.5,
          false,
          paint,
        );
        break;
      case MouthStyle.neutral:
        canvas.drawLine(
          Offset(mouthCenter.dx - r * 0.22, mouthCenter.dy),
          Offset(mouthCenter.dx + r * 0.22, mouthCenter.dy),
          paint,
        );
        break;
    }
  }

  void _paintHairBack(Canvas canvas, Offset c, double r) {
    if (config.hairStyle == HairStyle.long) {
      final paint = Paint()..color = config.hairColor;
      final path = Path()
        ..moveTo(c.dx - r * 0.95, c.dy - r * 0.2)
        ..quadraticBezierTo(
          c.dx - r * 1.1,
          c.dy + r * 1.3,
          c.dx - r * 0.5,
          c.dy + r * 1.4,
        )
        ..lineTo(c.dx - r * 0.3, c.dy + r * 0.5)
        ..close();
      canvas.drawPath(path, paint);

      final path2 = Path()
        ..moveTo(c.dx + r * 0.95, c.dy - r * 0.2)
        ..quadraticBezierTo(
          c.dx + r * 1.1,
          c.dy + r * 1.3,
          c.dx + r * 0.5,
          c.dy + r * 1.4,
        )
        ..lineTo(c.dx + r * 0.3, c.dy + r * 0.5)
        ..close();
      canvas.drawPath(path2, paint);
    }
  }

  void _paintHairFront(Canvas canvas, Offset c, double r) {
    final paint = Paint()..color = config.hairColor;

    switch (config.hairStyle) {
      case HairStyle.bald:
        return; // rien à dessiner
      case HairStyle.short:
        final rect = Rect.fromCenter(
          center: Offset(c.dx, c.dy - r * 0.55),
          width: r * 1.85,
          height: r * 1.15,
        );
        canvas.drawArc(rect, 3.35, 2.75, true, paint);
        break;
      case HairStyle.long:
        final rect = Rect.fromCenter(
          center: Offset(c.dx, c.dy - r * 0.55),
          width: r * 1.9,
          height: r * 1.2,
        );
        canvas.drawArc(rect, 3.35, 2.75, true, paint);
        break;
      case HairStyle.spiky:
        final baseY = c.dy - r * 0.45;
        final path = Path()..moveTo(c.dx - r * 0.9, baseY);
        const spikes = 6;
        for (int i = 0; i <= spikes; i++) {
          final x = c.dx - r * 0.9 + (r * 1.8 / spikes) * i;
          final peakY = baseY - (i.isEven ? r * 0.55 : r * 0.3);
          path.lineTo(x, peakY);
        }
        path
          ..lineTo(c.dx + r * 0.9, c.dy - r * 0.1)
          ..quadraticBezierTo(c.dx, c.dy - r * 0.65, c.dx - r * 0.9, c.dy - r * 0.1)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case HairStyle.curly:
        final baseCenter = Offset(c.dx, c.dy - r * 0.5);
        canvas.drawOval(
          Rect.fromCenter(center: baseCenter, width: r * 1.9, height: r * 1.1),
          paint,
        );
        final rand = [-0.8, -0.5, -0.2, 0.1, 0.4, 0.7];
        for (final t in rand) {
          canvas.drawCircle(
            Offset(c.dx + t * r, c.dy - r * 0.85),
            r * 0.22,
            paint,
          );
        }
        break;
      case HairStyle.cap:
        // Casquette : base arrondie + visière
        final rect = Rect.fromCenter(
          center: Offset(c.dx, c.dy - r * 0.55),
          width: r * 1.9,
          height: r * 1.25,
        );
        canvas.drawArc(rect, 3.4, 2.7, true, paint);
        final visor = Path()
          ..moveTo(c.dx - r * 0.1, c.dy - r * 0.35)
          ..quadraticBezierTo(
            c.dx + r * 0.75,
            c.dy - r * 0.5,
            c.dx + r * 0.85,
            c.dy - r * 0.2,
          )
          ..quadraticBezierTo(
            c.dx + r * 0.35,
            c.dy - r * 0.15,
            c.dx - r * 0.1,
            c.dy - r * 0.25,
          )
          ..close();
        canvas.drawPath(visor, paint);
        break;
    }
  }

  void _paintAccessory(Canvas canvas, Offset c, double r) {
    switch (config.accessory) {
      case Accessory.none:
        return;
      case Accessory.glasses:
      case Accessory.sunglasses:
        final eyeY = c.dy - r * 0.05;
        final dx = r * 0.42;
        final frameColor = Colors.black87;
        final lensPaint = Paint()
          ..color = config.accessory == Accessory.sunglasses
              ? Colors.black87
              : Colors.white.withOpacity(0.15);
        final framePaint = Paint()
          ..color = frameColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.055;

        for (final eyeCenter in [
          Offset(c.dx - dx, eyeY),
          Offset(c.dx + dx, eyeY),
        ]) {
          final rect = Rect.fromCenter(
              center: eyeCenter, width: r * 0.55, height: r * 0.4);
          canvas.drawOval(rect, lensPaint);
          canvas.drawOval(rect, framePaint);
        }
        canvas.drawLine(
          Offset(c.dx - dx + r * 0.27, eyeY),
          Offset(c.dx + dx - r * 0.27, eyeY),
          framePaint,
        );
        break;
      case Accessory.headband:
        final paint = Paint()..color = Colors.redAccent;
        final rect = Rect.fromCenter(
          center: Offset(c.dx, c.dy - r * 0.25),
          width: r * 1.9,
          height: r * 0.22,
        );
        canvas.drawRect(rect, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant MiiAvatarPainter oldDelegate) {
    return true;
  }
}
