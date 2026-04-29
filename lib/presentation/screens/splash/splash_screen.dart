import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:smart_campus_app/business_logic/auth_bloc/auth_state.dart';

class RuhunaSplashScreen extends StatefulWidget {
  const RuhunaSplashScreen({super.key});

  @override
  State<RuhunaSplashScreen> createState() => _RuhunaSplashScreenState();
}

class _RuhunaSplashScreenState extends State<RuhunaSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();

    // Auth status check කරලා navigate කරන්න
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final state = context.read<AuthBloc>().state;
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // 1. Background Mesh/Glow Layer
              const Positioned.fill(
                child: MeshBackgroundPainter(),
              ),

              // 2. Global Blur Layer (Glass Effect)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: Container(
                    color: AppColors.background.withOpacity(0.3),
                  ),
                ),
              ),

              // 3. Vignette for Focus
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        AppColors.background.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // 4. Main Content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 40),
                        _buildUniversityName(),
                        const SizedBox(height: 15),
                        _buildSmartCampusBadge(),
                        const SizedBox(height: 100),
                        _buildLoadingIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glassSurface.withOpacity(0.1),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricPurple.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.school_rounded,
        color: AppColors.textPrimary,
        size: 80,
      ),
    );
  }

  Widget _buildUniversityName() {
    return Column(
      children: [
        Text(
          "UNIVERSITY OF",
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 6,
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
        ),
        Text(
          "RUHUNA",
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartCampusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.3)),
        color: AppColors.glassSurface.withOpacity(0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.vibrantYellow,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "SMART CAMPUS",
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.electricPurple.withOpacity(0.8),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "Connecting to Campus...",
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

// Background Mesh Painter for the Glow effect
class MeshBackgroundPainter extends StatelessWidget {
  const MeshBackgroundPainter({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: _GlowCircle(color: AppColors.electricPurple.withOpacity(0.5), size: 400),
        ),
        Positioned(
          bottom: -50,
          left: -100,
          child: _GlowCircle(color: AppColors.softMagenta.withOpacity(0.4), size: 450),
        ),
        Positioned(
          top: 200,
          left: -50,
          child: _GlowCircle(color: AppColors.vibrantYellow.withOpacity(0.2), size: 300),
        ),
      ],
    );
  }
}

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