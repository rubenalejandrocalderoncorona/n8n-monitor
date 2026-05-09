import 'package:flutter/material.dart';
import '../app_theme.dart';

typedef WorkflowMetrics = ({int total, int active, int success, int errors});

class MetricsHeader extends StatelessWidget {
  final WorkflowMetrics metrics;

  const MetricsHeader({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          _MetricCard(label: 'Total', value: metrics.total, color: kOrange),
          const SizedBox(width: 8),
          _MetricCard(label: 'Active', value: metrics.active, color: kGreen),
          const SizedBox(width: 8),
          _MetricCard(label: 'Success', value: metrics.success, color: kGreen),
          const SizedBox(width: 8),
          _MetricCard(label: 'Errors', value: metrics.errors, color: kRed),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: kGrey)),
          ],
        ),
      ),
    );
  }
}
