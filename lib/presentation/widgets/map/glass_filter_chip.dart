// lib/presentation/widgets/map/glass_filter_chip.dart
import 'package:flutter/material.dart';
import 'package:smart_campus_app/core/constants/app_colors.dart';

class GlassFilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const GlassFilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  bool get isSelected => selectedValue == value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.electricPurple  // Selected - bright purple
              : Colors.grey.withValues(alpha: 0.8),  // Unselected - dark grey (visible)
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected 
                ? AppColors.electricPurple 
                : Colors.white.withValues(alpha: 0.3),  // Lighter border for visibility
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForLabel(),
              size: 16,
              color: isSelected ? Colors.white : Colors.white,  // Always white for contrast
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,  // Always white
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel() {
    switch (label.toLowerCase()) {
      case 'all': return Icons.apps;
      case 'academic': return Icons.school;
      case 'library': return Icons.local_library;
      case 'canteen': return Icons.restaurant;
      case 'sports': return Icons.sports_basketball;
      default: return Icons.location_on;
    }
  }
}