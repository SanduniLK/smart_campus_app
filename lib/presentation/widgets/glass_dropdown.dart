import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class GlassDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String label;
  final IconData icon;
  final void Function(String?)? onChanged;

  const GlassDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15), 
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item, 
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: Colors.black.withValues(alpha: 0.8),
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
            icon: Icon(
              Icons.arrow_drop_down_rounded, 
              color: Colors.white.withValues(alpha: 0.8),
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.8), 
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon, 
                color: Colors.white.withValues(alpha: 0.8), 
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ),
    );
  }
}