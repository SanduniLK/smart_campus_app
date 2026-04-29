import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final String Function(T) displayValue;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.validator,
    required this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(hint, style: const TextStyle(color: AppColors.textSecondary)),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(displayValue(item), style: const TextStyle(color: Colors.white)));
        }).toList(),
        onChanged: onChanged,
        validator: validator,
        dropdownColor: AppColors.glassSurface,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}