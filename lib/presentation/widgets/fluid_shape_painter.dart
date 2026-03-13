import 'package:flutter/material.dart';

class SolidFluidPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // 1. ප්‍රධාන fluid පාට මිශ්‍රණය (The Gradient along the sweep)
    // S-shape එකේ වංගුවට අනුව පාටවල් මිශ්‍ර වෙන්න හැදුවා
    final Gradient fluidGradient = SweepGradient(
      center: Alignment.center,
      colors: [
        const Color(0xFF8E54E9), // Purple
        const Color(0xFFE954B0), // Pink
        const Color(0xFFFBDD49), // Yellow
        const Color(0xFF8E54E9), // Loop back to Purple
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    final Paint tubePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 120 // තදට පේන්න මහත තව වැඩි කළා
      ..strokeCap = StrokeCap.round
      ..shader = fluidGradient.createShader(rect);

    // 2. ත්‍රිමාණ (3D) Tube ගතිය ගන්න දාන "Inner Glow" එක (White Highlights)
    // මේකෙන් තමයි අර glossy ගතිය එන්නේ
    final Paint highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50 // Highlights ටිකක් මහතට තිබීම වැදගත්
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final path = Path();
    
    // ආරම්භක ස්ථානය (S එකේ උඩ)
    path.moveTo(size.width * 0.35, size.height * 0.15);

    // S-shape එකේ වංගු (Curves) - Points ටිකක් වෙනස් කරලා ඩිසයින් එකට සමාන කළා
    path.cubicTo(
      size.width * 1.1, size.height * 0.1, 
      size.width * 0.8, size.height * 0.45, 
      size.width * 0.5, size.height * 0.45,
    );

    path.cubicTo(
      size.width * 0.1, size.height * 0.45, 
      size.width * 0.2, size.height * 0.85, 
      size.width * 0.9, size.height * 0.75,
    );

    // මුලින්ම ප්‍රධාන solid පාට අඳින්න
    canvas.drawPath(path, tubePaint);
    
    // ඊට උඩින් highlight එක ඇඳලා ත්‍රිමාණ (3D) Tube ගතිය ගන්න
    canvas.drawPath(path, highlightPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}