import 'package:flutter/material.dart';
import '../models/execution.dart';
import '../app_theme.dart';

class StatusChip extends StatelessWidget {
  final String? statusName;

  const StatusChip({super.key, this.statusName});

  @override
  Widget build(BuildContext context) {
    final status = _parse(statusName);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(status),
        const SizedBox(width: 4),
        Text(
          _label(status),
          style: TextStyle(
            fontSize: 11,
            color: _color(status),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(ExecutionStatus status) {
    if (status == ExecutionStatus.running) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: kOrange,
        ),
      );
    }
    return Icon(_icon(status), size: 13, color: _color(status));
  }

  ExecutionStatus _parse(String? name) {
    return switch (name) {
      'success' => ExecutionStatus.success,
      'error' => ExecutionStatus.error,
      'running' => ExecutionStatus.running,
      'waiting' => ExecutionStatus.waiting,
      _ => ExecutionStatus.unknown,
    };
  }

  IconData _icon(ExecutionStatus s) => switch (s) {
        ExecutionStatus.success => Icons.check_circle_outline,
        ExecutionStatus.error => Icons.cancel_outlined,
        ExecutionStatus.waiting => Icons.hourglass_empty,
        _ => Icons.radio_button_unchecked,
      };

  Color _color(ExecutionStatus s) => switch (s) {
        ExecutionStatus.success => kGreen,
        ExecutionStatus.error => kRed,
        ExecutionStatus.running => kOrange,
        ExecutionStatus.waiting => kOrange,
        _ => kGrey,
      };

  String _label(ExecutionStatus s) => switch (s) {
        ExecutionStatus.success => 'success',
        ExecutionStatus.error => 'error',
        ExecutionStatus.running => 'running',
        ExecutionStatus.waiting => 'waiting',
        _ => 'never run',
      };
}
