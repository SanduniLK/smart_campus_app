import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

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