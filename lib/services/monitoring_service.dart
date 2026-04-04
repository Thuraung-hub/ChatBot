import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MonitoringService {
  static Future<Trace?> startTrace(String name) async {
    if (kIsWeb) {
      return null;
    }

    try {
      final trace = FirebasePerformance.instance.newTrace(name);
      await trace.start();
      return trace;
    } catch (_) {
      return null;
    }
  }

  static Future<void> stopTrace(Trace? trace,
      {Map<String, String>? attributes}) async {
    if (trace == null) return;

    try {
      final attrs = attributes ?? <String, String>{};
      for (final entry in attrs.entries) {
        trace.putAttribute(entry.key, entry.value);
      }
      await trace.stop();
    } catch (_) {}
  }

  static Future<void> captureException(Object error,
      {StackTrace? stackTrace, String? hint}) async {
    try {
      if (hint != null && hint.isNotEmpty) {
        Sentry.configureScope((scope) {
          scope.setTag('operation_hint', hint);
        });
      }
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (_) {}
  }
}
