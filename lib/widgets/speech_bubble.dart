import 'package:flutter/material.dart';

/// A speech bubble widget with a triangular tail pointing downward toward
/// the coach avatar. Supports customisable colours for different moods.
class SpeechBubble extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const SpeechBubble({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0xFF1E1E2C),
    this.textColor = Colors.white,
    this.borderColor = const Color(0xFF3A3A5C),
  });

  @override
  State<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends State<SpeechBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeSlide = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeSlide,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeSlide.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - _fadeSlide.value)),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bubble body
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: widget.borderColor.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Triangle tail pointing down toward the avatar
          CustomPaint(
            size: const Size(24, 12),
            painter: _BubbleTailPainter(
              fillColor: widget.backgroundColor,
              borderColor: widget.borderColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _BubbleTailPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = fillColor);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final borderPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) =>
      fillColor != oldDelegate.fillColor || borderColor != oldDelegate.borderColor;
}
