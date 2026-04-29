import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DaySelector extends StatelessWidget {
  final int selectedDay;
  final Function(int) onDaySelected;
  final List<String> days;

  const DaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.days = const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(days.length, (index) {
          final dayNumber = index + 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(days[index], style: const TextStyle(color: Colors.white)),
              selected: selectedDay == dayNumber,
              onSelected: (selected) {
                if (selected) onDaySelected(dayNumber);
              },
              backgroundColor: AppColors.glassSurface,
              selectedColor: AppColors.electricPurple,
            ),
          );
        }),
      ),
    );
  }
}