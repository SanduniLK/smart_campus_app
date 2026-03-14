import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onScanQR;
  final VoidCallback onOpenMap;
  final VoidCallback onNotifications;

  const QuickActions({
    super.key,
    required this.onScanQR,
    required this.onOpenMap,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionButton(Icons.qr_code_scanner, 'Scan QR', AppColors.electricPurple, onScanQR)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(Icons.map, 'Campus Map', AppColors.softMagenta, onOpenMap)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(Icons.notifications, 'Notify', AppColors.vibrantYellow, onNotifications)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}