// lib/core/widgets/route_aware_status_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Applies a status-bar style that automatically reverts when this route is popped.
///
/// This is a thin wrapper around [AnnotatedRegion] which already handles style
/// restoration automatically. The previous implementation's dispose() method was
/// actually breaking this mechanism by setting a global style on pop.
///
/// ## ⚠️ IMPORTANT:
/// For most use cases, you should prefer:
/// 1. `AppBar.systemOverlayStyle` (simplest & most reliable)
/// 2. `ThemeData.appBarTheme.systemOverlayStyle` (global configuration)
/// 3. Direct `AnnotatedRegion` usage (manual control)
///
/// Only use this widget if you need consistent status bar styling across
/// routes that don't have AppBars.
///
/// Usage:
/// ```dart
/// RouteAwareStatusBar(
///   style: SystemUiOverlayStyle(
///     statusBarColor: Colors.transparent,
///     statusBarIconBrightness: Brightness.light,
///   ),
///   child: Scaffold(...),
/// )
/// ```
class RouteAwareStatusBar extends StatelessWidget {
  final SystemUiOverlayStyle style;
  final Widget child;

  const RouteAwareStatusBar({
    super.key,
    required this.style,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion automatically saves & restores the previous style
    // when this widget leaves the tree. No dispose() needed!
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: child,
    );
  }
}