enum ExecutionStatus { success, error, running, waiting, unknown }

class Execution {
  final String id;
  final String workflowId;
  final ExecutionStatus status;
  final DateTime startedAt;
  final DateTime? stoppedAt;
  final String? mode;

  const Execution({
    required this.id,
    required this.workflowId,
    required this.status,
    required this.startedAt,
    this.stoppedAt,
    this.mode,
  });

  Duration? get duration => stoppedAt?.difference(startedAt);

  factory Execution.fromJson(Map<String, dynamic> json) {
    return Execution(
      id: json['id'].toString(),
      workflowId: json['workflowId'].toString(),
      status: _parseStatus(json['status'] as String?),
      startedAt: DateTime.parse(json['startedAt'] as String),
      stoppedAt: json['stoppedAt'] != null
          ? DateTime.parse(json['stoppedAt'] as String)
          : null,
      mode: json['mode'] as String?,
    );
  }

  static ExecutionStatus _parseStatus(String? raw) {
    return switch (raw) {
      'success' => ExecutionStatus.success,
      'error' => ExecutionStatus.error,
      'running' => ExecutionStatus.running,
      'waiting' => ExecutionStatus.waiting,
      _ => ExecutionStatus.unknown,
    };
  }
}
