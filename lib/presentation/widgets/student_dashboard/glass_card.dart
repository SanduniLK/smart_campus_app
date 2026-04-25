import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class GlassCard extends StatefulWidget {
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
  final bool enableGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blurIntensity = 10,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1,
    this.backgroundColor,
    this.width,
    this.height,
    this.enableGlow = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.enableGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableGlow) {
      return _buildGlassCard(glowValue: 0.3);
    }
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return _buildGlassCard(glowValue: _glowAnimation.value);
      },
    );
  }
  
  Widget _buildGlassCard({required double glowValue}) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.enableGlow
            ? [
                BoxShadow(
                  color: AppColors.electricPurple.withValues(alpha: glowValue * 0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurIntensity,
            sigmaY: widget.blurIntensity,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.glassSurface,
              border: Border.all(
                color: (widget.borderColor ?? AppColors.cardBorder).withValues(
                  alpha: widget.enableGlow ? 0.5 + glowValue * 0.3 : 1.0,
                ),
                width: widget.borderWidth,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}