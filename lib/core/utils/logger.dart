// lib/core/utils/logger.dart

import 'package:logger/logger.dart';

/// 📋 Global Logger Instance
///
/// **Usage:**
/// ```dart
/// import 'package:travel265/core/utils/logger.dart';
///
/// logger.d('Debug message');
/// logger.i('Info message');
/// logger.w('Warning message');
/// logger.e('Error message', error: e, stackTrace: stackTrace);
/// ```
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // No method call stack
    errorMethodCount: 5, // Show 5 stack frames for errors
    lineLength: 80, // Width of output
    colors: true, // Colorful logs
    printEmojis: true, // Print emojis
    printTime: true, // Print timestamp
  ),
  filter: _CustomLogFilter(),
);

/// Custom log filter
/// - Shows all logs in debug mode
/// - Only shows warnings and errors in release mode
class _CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In debug mode, show all logs
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      return true;
    }

    // In release mode, only show warnings and errors
    return event.level.index >= Level.warning.index;
  }
}