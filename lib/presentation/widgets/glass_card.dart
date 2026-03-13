import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';


class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurIntensity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blurIntensity = 10,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurIntensity,
            sigmaY: blurIntensity,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.glassSurface,
              border: Border.all(
                color: borderColor ?? AppColors.cardBorder,
                width: borderWidth,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}