import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class AnimatedGlassBackground extends StatefulWidget {
  const AnimatedGlassBackground({super.key});

  @override
  State<AnimatedGlassBackground> createState() =>
      _AnimatedGlassBackgroundState();
}

class _AnimatedGlassBackgroundState extends State<AnimatedGlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // slower = smoother
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: GlassSkinPainter(animation: _controller.value),
          );
        },
      ),
    );
  }
}

class GlassSkinPainter extends CustomPainter {
  final double animation;

  GlassSkinPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35) // reduced
      ..blendMode = BlendMode.screen;

    double wave1 = math.sin(animation * 2 * math.pi) * 50;
    double wave2 = math.cos(animation * 2 * math.pi) * 50;
    double wave3 = math.sin(animation * 2 * math.pi + 2) * 45;
    double wave4 = math.cos(animation * 2 * math.pi + 2) * 45;

    double opacity1 = 0.4 + (math.sin(animation * 2 * math.pi) * 0.1);
    double opacity2 = 0.35 + (math.cos(animation * 2 * math.pi) * 0.1);
    double opacity3 = 0.3 + (math.sin(animation * 2 * math.pi + 2) * 0.1);

    // Main blobs
    _drawCircle(canvas, size, paint,
        size.width * 0.2 + wave1, size.height * 0.2 + wave2, 220,
        AppColors.electricPurple, opacity1);

    _drawCircle(canvas, size, paint,
        size.width * 0.8 + wave2, size.height * 0.4 + wave1, 240,
        AppColors.softMagenta, opacity2);

    _drawCircle(canvas, size, paint,
        size.width * 0.85 + wave3, size.height * 0.75 + wave4, 220,
        AppColors.vibrantYellow, opacity3);

    _drawCircle(canvas, size, paint,
        size.width * 0.5 + wave4, size.height * 0.5 + wave3, 260,
        AppColors.electricPurple, opacity2 * 0.9);

    // Particles (reduced)
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    for (int i = 0; i < 10; i++) {
      double angle = animation * 2 * math.pi + (i * 0.5);

      double x = size.width * (0.2 + 0.6 * (i / 10)) +
          math.sin(angle) * 50;
      double y = size.height * (0.3 + 0.4 * (i / 10)) +
          math.cos(angle) * 50;

      paint.color = AppColors.withOpacity(
          i % 2 == 0
              ? AppColors.electricPurple
              : AppColors.softMagenta,
          0.2);

      canvas.drawCircle(Offset(x, y), 25, paint);
    }

    // Light streaks
    paint
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < 5; i++) {
      double startX =
          size.width * (0.1 + (i * 0.15)) + math.sin(animation * 2 + i) * 30;
      double startY = size.height * 0.1;

      double endX =
          size.width * (0.3 + (i * 0.1)) + math.cos(animation * 2 + i) * 30;
      double endY = size.height * 0.9;

      paint.color = AppColors.withOpacity(
          AppColors.electricPurple, 0.15);

      canvas.drawLine(
          Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  void _drawCircle(Canvas canvas, Size size, Paint paint,
      double x, double y, double radius, Color color, double opacity) {
    paint.color = AppColors.withOpacity(color, opacity);
    canvas.drawCircle(Offset(x, y), radius, paint);
  }

  @override
  bool shouldRepaint(covariant GlassSkinPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}