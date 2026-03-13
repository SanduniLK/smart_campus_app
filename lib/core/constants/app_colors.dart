import 'package:flutter/material.dart';

class AppColors {
  // Dark Theme Background
  static const Color background = Color(0xFF0B0E14);
  
  // Glass Morphism Colors
  static const Color glassSurface = Color(0x801F222B); // 50% opacity
  static const Color cardBorder = Color(0xFF353945);
  
  // Gradient Colors
  static const Color electricPurple = Color(0xFF8E54E9);
  static const Color softMagenta = Color(0xFFFF5CCC);
  static const Color vibrantYellow = Color(0xFFFBDD49);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9A9FA1);
  
  // Functional Colors
  static const Color success = vibrantYellow;
  static const Color error = Color(0xFFE53935);
  
  // Helper method for opacity - මෙය එකතු කරන්න
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}