import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class AILogo extends StatefulWidget {
  final double size;
  const AILogo({super.key, this.size = 120});

  @override
  State<AILogo> createState() => _AILogoState();
}

class _AILogoState extends State<AILogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: LogoPainter(_controller.value),
        );
      },
    );
  }
}

class LogoPainter extends CustomPainter {
  final double progress;
  LogoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw Outer Glow
    final glowPaint = Paint()
      ..color = AppTheme.primaryColor.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, radius * 0.9, glowPaint);

    // 2. Draw Waves / Orbits
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppTheme.secondaryColor.withValues(alpha: 0.3);

    for (int i = 0; i < 3; i++) {
      final orbitRadius = radius * (0.6 + (i * 0.1));
      final rotation = progress * 2 * math.pi + (i * math.pi / 3);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);

      final rect = Rect.fromCircle(center: Offset.zero, radius: orbitRadius);
      canvas.drawArc(rect, 0, math.pi * 1.5, false, orbitPaint);

      // Orbit head
      final headX = orbitRadius * math.cos(0);
      final headY = orbitRadius * math.sin(0);
      canvas.drawCircle(
        Offset(headX, headY),
        3,
        Paint()..color = AppTheme.secondaryColor,
      );

      canvas.restore();
    }

    // 3. Central Core
    final coreGradient = RadialGradient(
      colors: [
        AppTheme.primaryColor,
        AppTheme.primaryColor.withValues(alpha: 0.8),
      ],
    );

    final corePaint = Paint()
      ..shader = coreGradient.createShader(
        Rect.fromCircle(center: center, radius: radius * 0.45),
      );

    // Core pulse effect
    final pulseScale = 1.0 + (0.05 * math.sin(progress * 2 * math.pi));
    canvas.drawCircle(center, radius * 0.45 * pulseScale, corePaint);

    // 4. Central Icon (Procedural sparkle)
    final iconPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2);
      final length = radius * 0.2;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * 5,
          center.dy + math.sin(angle) * 5,
        ),
        Offset(
          center.dx + math.cos(angle) * length,
          center.dy + math.sin(angle) * length,
        ),
        iconPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) => true;
}
