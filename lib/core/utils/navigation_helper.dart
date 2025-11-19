// lib/core/utils/navigation_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavigationHelper {
  static Future<void> navigateWithFeedback({
    required BuildContext context,
    required Widget screen,
  }) async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Navigate
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}