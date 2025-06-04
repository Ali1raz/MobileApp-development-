import 'package:flutter/material.dart';

class CompletionProgress extends StatelessWidget {
  final Map<String, dynamic> taskCompletion;

  const CompletionProgress({super.key, required this.taskCompletion});

  double _getCompletionRate() {
    try {
      final rate = taskCompletion['completion_rate'];
      if (rate == null) return 0.0;

      if (rate is double) {
        return rate / 100.0;
      } else if (rate is String) {
        final doubleValue = double.tryParse(rate);
        return doubleValue != null ? doubleValue / 100.0 : 0.0;
      } else if (rate is int) {
        return rate / 100.0;
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error calculating completion rate: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = _getCompletionRate();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: completionRate,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Text(
            '${(completionRate * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
