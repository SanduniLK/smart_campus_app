import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const TabBar(
              indicator: BoxDecoration(),
              labelColor: AppColors.electricPurple,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(icon: Icon(Icons.home_rounded), text: 'Home'),
                Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Schedule'),
                Tab(icon: Icon(Icons.event_rounded), text: 'Events'),
                Tab(icon: Icon(Icons.person_rounded), text: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}