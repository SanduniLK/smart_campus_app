import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class QuickAccessGrid extends StatelessWidget {
  final VoidCallback onTimetableTap;
  final VoidCallback onCampusMapTap;
  final VoidCallback onQRPassTap;
  final VoidCallback onEventsTap;

  const QuickAccessGrid({
    super.key,
    required this.onTimetableTap,
    required this.onCampusMapTap,
    required this.onQRPassTap,
    required this.onEventsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickAccessTile(
                icon: Icons.schedule,
                title: 'Timetable',
                subtitle: 'Week view',
                iconColor: AppColors.electricPurple,
                onTap: onTimetableTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickAccessTile(
                icon: Icons.map,
                title: 'Campus Map',
                subtitle: 'Live location',
                iconColor: AppColors.success,
                onTap: onCampusMapTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickAccessTile(
                icon: Icons.qr_code,
                title: 'My QR Pass',
                subtitle: 'Event entry',
                iconColor: AppColors.vibrantYellow,
                onTap: onQRPassTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickAccessTile(
                icon: Icons.celebration,
                title: 'Events',
                subtitle: 'Register now',
                iconColor: AppColors.error,
                onTap: onEventsTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QuickAccessTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const QuickAccessTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}