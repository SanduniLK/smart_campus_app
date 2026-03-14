import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildEventCard(
              'Tech Symposium 2024',
              'March 25, 2024 • 9:00 AM',
              'Main Auditorium',
              'Register',
              isFeatured: true,
            ),
            const SizedBox(height: 12),
            _buildEventCard(
              'Career Fair',
              'March 28, 2024 • 10:00 AM',
              'Engineering Faculty',
              'Registered',
              isRegistered: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(String title, String date, String venue, String buttonText,
      {bool isRegistered = false, bool isFeatured = false}) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFeatured
                        ? [AppColors.vibrantYellow, AppColors.electricPurple]
                        : [AppColors.electricPurple, AppColors.softMagenta],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFeatured ? Icons.star : Icons.event,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      venue,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              gradient: isRegistered
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.electricPurple, AppColors.softMagenta],
                    ),
              color: isRegistered ? Colors.green.withValues(alpha: 0.2) : null,
              borderRadius: BorderRadius.circular(12),
              border: isRegistered ? Border.all(color: Colors.green) : null,
            ),
            child: ElevatedButton(
              onPressed: isRegistered ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isRegistered ? Colors.green : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}