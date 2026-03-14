import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';
import 'package:smart_campus_app/data/models/student_model/dashboard_models.dart';
import 'package:smart_campus_app/presentation/widgets/glass_card.dart';

class EventsList extends StatelessWidget {
  final VoidCallback onViewAll;

  const EventsList({super.key, required this.onViewAll});

  List<EventModel> _getEvents() {
    return [
      EventModel(
        title: 'Tech Symposium 2024',
        date: 'Tomorrow, 10:00 AM',
        location: 'Main Auditorium',
        emoji: '🚀',
      ),
      EventModel(
        title: 'Career Fair',
        date: 'Friday, 9:00 AM',
        location: 'Engineering Faculty',
        emoji: '💼',
        isRegistered: true,
      ),
      EventModel(
        title: 'Workshop on AI',
        date: 'Next Monday, 2:00 PM',
        location: 'CS Lab',
        emoji: '🤖',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Events',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.electricPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._getEvents().map((event) => _buildEventCard(event)).toList(),
      ],
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.electricPurple, AppColors.softMagenta],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(event.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(event.date, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 10, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(event.location, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            if (event.isRegistered)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Registered',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
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