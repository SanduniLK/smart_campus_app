import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';



class MeshGradientBackground extends StatelessWidget {
  final Widget? child; // පසුබිමට උඩින් පෙන්විය යුතු content එක

  const MeshGradientBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base dark background
        Container(color: AppColors.background),
        
        // 2. Glow Circles (මෘදු ආලෝක රවුම්)
        // මේවායේ opacity, size සහ position එක වෙනස් කිරීමෙන් 
        // ඔයාට කැමති Mesh look එකක් හදාගන්න පුළුවන්.

        // Purple glow (top left)
        Positioned(
          top: -100,
          left: -100,
          child: _GlowCircle(
            color: AppColors.electricPurple.withOpacity(0.3),
            size: 400,
          ),
        ),
        
        // Magenta glow (center right)
        Positioned(
          top: 300,
          right: -80,
          child: _GlowCircle(
            color: AppColors.softMagenta.withOpacity(0.25),
            size: 350,
          ),
        ),
        
        // Yellow glow (bottom center)
        Positioned(
          bottom: -150,
          left: 50,
          child: _GlowCircle(
            color: AppColors.vibrantYellow.withOpacity(0.2),
            size: 300,
          ),
        ),

        // 3. ✨ වැදගත්ම කොටස: Global Blur Layer
        // මේ BackdropFilter එකෙන් තමයි අර glow circles ඔක්කොම 
        // එකිනෙක ලස්සනට මිශ්‍ර (blend) කරන්නේ.
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),
        ),
        
        // 4. Child content (Buttons, Text, etc.)
        if (child != null) child!,
      ],
    );
  }
}

// Reusable widget එකක් විදිහට Glow Circle එක වෙන් කළා Code එක පිරිසිදුව තියාගන්න
class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}