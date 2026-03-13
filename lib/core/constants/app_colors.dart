import 'package:flutter/material.dart';

class AppColors {
  // --- Dark Theme Backgrounds ---
  static const Color background = Color(0xFF0B0E14);    // Deep dark navy base
  static const Color scaffoldBg = Color(0xFF0B0E14);

  // --- Glassmorphism & Cards ---
  // මේවා තමයි අර design එකේ තියෙන glass effect එක ගන්න පාවිච්චි කරන්නේ
  static const Color glassSurface = Color(0x601F222B);  // 60% opacity glass
  static const Color cardBorder = Color(0xFF353945);    // Subtle grey border for cards
  static const Color cardBg = Color(0xFF1F222B);        // Solid card background

  // --- Gradient / Mesh Glow Colors ---
  // Background එකේ තියෙන ලස්සන glow එකට පාවිච්චි කරන වර්ණ
  static const Color electricPurple = Color(0xFF8E54E9); // Dominant purple
  static const Color softMagenta = Color(0xFFFF5CCC);    // Soft pink/magenta
  static const Color vibrantYellow = Color(0xFFFBDD49);  // Pop yellow (Gold)
  static const Color electricBlue = Color(0xFF6AA6FF);   // Optional blue glow

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFFFFFFFF);    // Pure white for headings
  static const Color textSecondary = Color(0xFF9A9FA1);  // Muted grey for descriptions
  static const Color textHint = Color(0x66FFFFFF);       // Faded white for hints

  // --- Functional Colors ---
  static const Color primary = electricPurple;
  static const Color success = Color(0xFF4CAF50);        // Green
  static const Color error = Color(0xFFE53935);          // Red
  static const Color warning = vibrantYellow;            // Yellow/Gold

  // --- Helper Methods ---
  // Flutter වල අලුත්ම values ක්‍රමයට opacity පාවිච්චි කරන්න මේක උදව් වෙනවා
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}