// lib/widgets/disposable_annotated_region.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Guarantees the status-bar style is reset when this route is popped.
class DisposableAnnotatedRegion extends StatefulWidget {
  final SystemUiOverlayStyle value;
  final Widget child;
  const DisposableAnnotatedRegion({
    required this.value,
    required this.child,
    super.key,
  });

  @override
  State<DisposableAnnotatedRegion> createState() =>
      _DisposableAnnotatedRegionState();
}

class _DisposableAnnotatedRegionState
    extends State<DisposableAnnotatedRegion> {
  @override
  Widget build(BuildContext context) =>
      AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.value,
        child: widget.child,
      );

  @override
  void dispose() {
    // Reset to a sane default so the next route doesn't inherit ours.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.dispose();
  }
}