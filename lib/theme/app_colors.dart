import 'package:flutter/material.dart';

/// GeoFamiliar palette - a lively but balanced set: mint, coral, amber,
/// night-ink and cream. Deliberately avoids a one-note purple/blue or beige.
class AppColors {
  AppColors._();

  // Core brand hues
  static const mint = Color(0xFF4DD0B1);
  static const mintDeep = Color(0xFF2BB99A);
  static const coral = Color(0xFFFF8A65);
  static const coralDeep = Color(0xFFFF6F61);
  static const amber = Color(0xFFFFC04D);
  static const rose = Color(0xFFFF6F91);
  static const violet = Color(0xFFB388FF);
  static const skyBlue = Color(0xFF5C9DFF);

  // Night ink (text / dark surfaces)
  static const ink = Color(0xFF1E2433);
  static const inkSoft = Color(0xFF3A4256);
  static const inkMuted = Color(0xFF7B8499);

  // Cream / surfaces
  static const cream = Color(0xFFFFFBF4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF4F7F6);
  static const hairline = Color(0xFFE7ECEA);

  // Feedback
  static const success = Color(0xFF3FBF8F);
  static const warning = Color(0xFFF5A524);

  /// The warm sky gradient used behind the companion.
  static const dawnGradient = [Color(0xFFFFF3E6), Color(0xFFEAFBF5)];

  /// Night gradient for evolution / premium moments.
  static const nightGradient = [Color(0xFF2A3350), Color(0xFF1E2433)];
}
