import 'dart:math' as math;
import 'package:flutter/material.dart';

class MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // More colorful blobs with better placement
    
    // Electric Purple (Top Left)
    paint.color = const Color(0xFF8E54E9).withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.15),
      220,
      paint,
    );

    // Hot Pink (Top Right)
    paint.color = const Color(0xFFFF5CCC).withValues(alpha: 0.6);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      200,
      paint,
    );

    // Deep Magenta (Center)
    paint.color = const Color(0xFFE954B0).withValues(alpha: 0.65);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      240,
      paint,
    );

    // Vibrant Yellow (Bottom Right)
    paint.color = const Color(0xFFFBDD49).withValues(alpha: 0.7);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      210,
      paint,
    );

    // Bright Orange (Middle Left)
    paint.color = const Color(0xFFFF934A).withValues(alpha: 0.5);
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.65),
      180,
      paint,
    );

    // Cyan Blue (Bottom Left)
    paint.color = const Color(0xFF54E9E9).withValues(alpha: 0.45);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.85),
      160,
      paint,
    );

    // Deep Purple (Center Right)
    paint.color = const Color(0xFF6B3FA0).withValues(alpha: 0.5);
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.55),
      190,
      paint,
    );

    // Additional small accent blobs
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    
    paint.color = const Color(0xFFF472B6).withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.8),
      120,
      paint,
    );

    paint.color = const Color(0xFFA78BFA).withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.25),
      130,
      paint,
    );

    paint.color = const Color(0xFFFCD34D).withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.3),
      110,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}