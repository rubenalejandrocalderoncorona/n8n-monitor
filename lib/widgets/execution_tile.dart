import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/execution.dart';
import '../app_theme.dart';

class ExecutionTile extends StatelessWidget {
  final Execution execution;
  final VoidCallback onDelete;

  const ExecutionTile({
    super.key,
    required this.execution,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _statusIcon(),
      title: Text(
        _modeLabel(),
        style: const TextStyle(color: kOnSurface, fontSize: 14),
      ),
      subtitle: Text(
        timeago.format(execution.startedAt),
        style: const TextStyle(color: kGrey, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (execution.duration != null)
            Text(
              _formatDuration(execution.duration!),
              style: const TextStyle(color: kGrey, fontSize: 12),
            ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: kGrey),
            tooltip: 'Delete execution',
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _statusIcon() {
    if (execution.status == ExecutionStatus.running) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: kOrange),
      );
    }
    final (icon, color) = switch (execution.status) {
      ExecutionStatus.success => (Icons.check_circle, kGreen),
      ExecutionStatus.error => (Icons.cancel, kRed),
      ExecutionStatus.waiting => (Icons.hourglass_empty, kOrange),
      _ => (Icons.help_outline, kGrey),
    };
    return Icon(icon, color: color, size: 20);
  }

  String _modeLabel() {
    return switch (execution.mode) {
      'manual' => 'Manual run',
      'trigger' => 'Triggered',
      'webhook' => 'Webhook',
      'scheduled' => 'Scheduled',
      _ => execution.mode ?? 'Run',
    };
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }
}
