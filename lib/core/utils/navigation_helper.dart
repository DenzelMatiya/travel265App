// lib/core/utils/navigation_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🧭 **Navigation Helper**
///
/// Provides navigation with haptic feedback for better UX
class NavigationHelper {
  static Future<void> navigateWithFeedback({
    required BuildContext context,
    required Widget screen,
  }) async {
    // Haptic feedback for tactile response
    HapticFeedback.lightImpact();

    // Navigate with explicit Route type to avoid type errors
    await Navigator.push<Object?>(
      context,
      MaterialPageRoute<Object?>(builder: (context) => screen),
    );
  }

  /// 🔙 Navigate back with feedback
  static void popWithFeedback(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  /// 🔄 Navigate and replace current screen
  static Future<void> navigateReplacementWithFeedback({
    required BuildContext context,
    required Widget screen,
  }) async {
    HapticFeedback.lightImpact();
    await Navigator.pushReplacement<Object?, Object?>(
      context,
      MaterialPageRoute<Object?>(builder: (context) => screen),
    );
  }

  /// 🗑️ Navigate and remove all previous routes
  static Future<void> navigateAndRemoveUntil({
    required BuildContext context,
    required Widget screen,
  }) async {
    HapticFeedback.lightImpact();
    await Navigator.pushAndRemoveUntil<Object?>(
      context,
      MaterialPageRoute<Object?>(builder: (context) => screen),
          (Route<dynamic> route) => false, // Remove all previous routes
    );
  }
}