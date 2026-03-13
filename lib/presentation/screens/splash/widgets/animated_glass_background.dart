import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class AnimatedGlassBackground extends StatefulWidget {
  const AnimatedGlassBackground({super.key});

  @override
  State<AnimatedGlassBackground> createState() => _AnimatedGlassBackgroundState();
}

class _AnimatedGlassBackgroundState extends State<AnimatedGlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
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
          painter: GlassSkinPainter(animation: _controller.value),
        );
      },
    );
  }
}

class GlassSkinPainter extends CustomPainter {
  final double animation;

  GlassSkinPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100)
      ..blendMode = BlendMode.screen;

    // Smooth wave movements for glass effect
    double wave1 = math.sin(animation * 2 * math.pi) * 60;
    double wave2 = math.cos(animation * 2 * math.pi) * 60;
    double wave3 = math.sin(animation * 2 * math.pi + 2) * 55;
    double wave4 = math.cos(animation * 2 * math.pi + 2) * 55;
    
    // Opacity pulses for glass transparency
    double opacity1 = 0.4 + (math.sin(animation * 2 * math.pi) * 0.15);
    double opacity2 = 0.35 + (math.cos(animation * 2 * math.pi) * 0.15);
    double opacity3 = 0.3 + (math.sin(animation * 2 * math.pi + 2) * 0.15);

    // Electric Purple Glass Orb (Top Left)
    paint.color = AppColors.withOpacity(
      AppColors.electricPurple, 
      opacity1
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.2 + wave1,
        size.height * 0.2 + wave2,
      ),
      280,
      paint,
    );

    // Soft Magenta Glass Orb (Center Right)
    paint.color = AppColors.withOpacity(
      AppColors.softMagenta, 
      opacity2
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.8 + wave2,
        size.height * 0.4 + wave1,
      ),
      300,
      paint,
    );

    // Vibrant Yellow Glass Orb (Bottom Right)
    paint.color = AppColors.withOpacity(
      AppColors.vibrantYellow, 
      opacity3
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.85 + wave3,
        size.height * 0.75 + wave4,
      ),
      260,
      paint,
    );

    // Electric Purple Glass Orb (Center)
    paint.color = AppColors.withOpacity(
      AppColors.electricPurple, 
      opacity2 * 0.9
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.5 + wave4,
        size.height * 0.5 + wave3,
      ),
      320,
      paint,
    );

    // Soft Magenta Glass Orb (Bottom Left)
    paint.color = AppColors.withOpacity(
      AppColors.softMagenta, 
      opacity1 * 0.8
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.15 + wave2,
        size.height * 0.8 + wave1,
      ),
      240,
      paint,
    );

    // Vibrant Yellow Glass Orb (Top Right)
    paint.color = AppColors.withOpacity(
      AppColors.vibrantYellow, 
      opacity3 * 0.7
    );
    canvas.drawCircle(
      Offset(
        size.width * 0.9 + wave1,
        size.height * 0.2 + wave3,
      ),
      220,
      paint,
    );

    // Additional Glass Particles for depth
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);
    
    for (int i = 0; i < 20; i++) {
      double angle = animation * 2 * math.pi + (i * 0.3);
      double radius = 80 + (i * 3);
      
      double x = size.width * (0.2 + 0.6 * (i / 20)) + math.sin(angle) * 70;
      double y = size.height * (0.3 + 0.4 * (i / 20)) + math.cos(angle) * 70;
      
      Color color;
      double particleOpacity;
      
      if (i % 3 == 0) {
        color = AppColors.electricPurple;
        particleOpacity = 0.25 + (math.sin(angle) * 0.1);
      } else if (i % 3 == 1) {
        color = AppColors.softMagenta;
        particleOpacity = 0.2 + (math.cos(angle) * 0.08);
      } else {
        color = AppColors.vibrantYellow;
        particleOpacity = 0.15 + (math.sin(angle + 1) * 0.06);
      }
      
      paint.color = AppColors.withOpacity(color, particleOpacity);
      canvas.drawCircle(Offset(x, y), radius * 0.4, paint);
    }

    // Glass Light Streaks
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
    paint.strokeWidth = 5;
    paint.style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      double startX = size.width * (0.1 + (i * 0.12)) + math.sin(animation * 2 + i) * 50;
      double startY = size.height * 0.1 + math.cos(animation * 2 + i) * 50;
      double endX = size.width * (0.3 + (i * 0.08)) + math.cos(animation * 2 + i) * 50;
      double endY = size.height * 0.9 + math.sin(animation * 2 + i) * 50;

      paint.color = AppColors.withOpacity(
        i % 3 == 0 ? AppColors.electricPurple : 
        i % 3 == 1 ? AppColors.softMagenta : 
        AppColors.vibrantYellow,
        0.15
      );

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // Glass Mesh Gradient Overlay
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
    paint.style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      double x = size.width * (0.1 + 0.8 * (i / 10)) + math.sin(animation * 2 + i) * 40;
      double y = size.height * (0.2 + 0.6 * (i / 10)) + math.cos(animation * 2 + i) * 40;
      
      paint.color = AppColors.withOpacity(
        i % 3 == 0 ? AppColors.electricPurple : 
        i % 3 == 1 ? AppColors.softMagenta : 
        AppColors.vibrantYellow,
        0.12
      );
      
      canvas.drawCircle(Offset(x, y), 120, paint);
    }
  }

  @override
  bool shouldRepaint(covariant GlassSkinPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// MeshGradientBackground class එක වෙනම file එකකට ගෙනියන්න වඩා හොඳයි
// නමුත් එකම file එකේ තියෙනවා නම් මෙහෙම දාන්න
class MeshGradientBackground extends StatelessWidget {
  final Widget? child;

  const MeshGradientBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(color: AppColors.background),
        
        // Purple glow (top left)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.electricPurple.withValues(alpha: 0.4),
                  AppColors.electricPurple.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        
        // Magenta glow (center)
        Positioned(
          top: 200,
          right: -50,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.softMagenta.withValues(alpha: 0.35),
                  AppColors.softMagenta.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        
        // Yellow glow (bottom)
        Positioned(
          bottom: -80,
          left: 50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.vibrantYellow.withValues(alpha: 0.25),
                  AppColors.vibrantYellow.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        
        // Blur layers for glass effect
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                color: AppColors.withOpacity(AppColors.background, 0.3),
              ),
            ),
          ),
        ),
        
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: AppColors.withOpacity(AppColors.glassSurface, 0.2),
              ),
            ),
          ),
        ),
        
        // Content
        if (child != null) child!,
      ],
    );
  }
}