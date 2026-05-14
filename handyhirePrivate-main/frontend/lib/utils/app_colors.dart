import 'package:flutter/material.dart';

/// Unified colour palette used by both customer and provider sides of the app.
///
/// NOTE: This file previously only existed as `lib/screens/customer/app_colors.dart`
/// and every file under `lib/screens/provider/` was importing it from
/// `../../utils/app_colors.dart` — which didn't exist. That caused the entire
/// provider half of the app to fail compilation. Moved here so both sides share
/// the same palette.
class AppColors {
  // Brand palette
  static const Color background = Color(0xFF0B1E3F); // Deep navy
  static const Color accent = Color(0xFF8EBBFF);     // Light blue
  static const Color text = Color(0xFFFFFFFF);       // White
  static const Color secondary = Color(0xFF1E355B);  // Lighter navy

  // Provider-flow additions
  static const Color success = Color(0xFF27AE60);    // Green (used by provider UploadProof / PaymentSuccess / JobHistory)
  static const Color danger = Color(0xFFE74C3C);     // Red  (used for reject / logout / error states)
  static const Color gold = Color(0xFFB18E44);       // Gold (admin/auth accent)
  static const Color silver = Color(0xFFC0C0C2);     // Silver (form fill)
}
