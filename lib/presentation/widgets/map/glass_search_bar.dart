// lib/presentation/widgets/map/glass_search_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassSearchBar extends StatelessWidget {
  final Function(String)? onChanged;
  final TextEditingController? controller;

  const GlassSearchBar({
    super.key,
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),  // Dark background
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),  // White text
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Search buildings...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}