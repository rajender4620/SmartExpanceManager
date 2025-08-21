import 'package:flutter/material.dart';

enum InsightType {
  warning,
  success,
  info,
  tip,
}

class Insight {
  final String message;
  final InsightType type;
  final DateTime timestamp;

  const Insight({
    required this.message,
    required this.type,
    required this.timestamp,
  });

  IconData get icon {
    switch (type) {
      case InsightType.warning:
        return Icons.warning_rounded;
      case InsightType.success:
        return Icons.check_circle_rounded;
      case InsightType.info:
        return Icons.info_rounded;
      case InsightType.tip:
        return Icons.lightbulb_rounded;
    }
  }

  String get emoji {
    switch (type) {
      case InsightType.warning:
        return '⚠️';
      case InsightType.success:
        return '✅';
      case InsightType.info:
        return 'ℹ️';
      case InsightType.tip:
        return '💡';
    }
  }

  Color get color {
    switch (type) {
      case InsightType.warning:
        return const Color(0xFFFF9800);
      case InsightType.success:
        return const Color(0xFF4CAF50);
      case InsightType.info:
        return const Color(0xFF2196F3);
      case InsightType.tip:
        return const Color(0xFF9C27B0);
    }
  }

  LinearGradient get gradient {
    final baseColor = color;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor.withOpacity(0.1),
        baseColor.withOpacity(0.2),
      ],
    );
  }
}
