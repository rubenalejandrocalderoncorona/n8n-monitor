class Workflow {
  final String id;
  final String name;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, dynamic>> nodes;
  final String? lastExecutionStatus;

  const Workflow({
    required this.id,
    required this.name,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    required this.nodes,
    this.lastExecutionStatus,
  });

  factory Workflow.fromJson(Map<String, dynamic> json) {
    return Workflow(
      id: json['id'].toString(),
      name: json['name'] as String,
      active: json['active'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      nodes: (json['nodes'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
  }

  bool get isManuallyTriggerable {
    const autoTriggerTypes = {
      'n8n-nodes-base.scheduleTrigger',
      'n8n-nodes-base.webhook',
      'n8n-nodes-base.emailTrigger',
      'n8n-nodes-base.cron',
    };
    return !nodes.any((n) => autoTriggerTypes.contains(n['type'] as String?));
  }

  Workflow copyWith({bool? active, String? lastExecutionStatus}) {
    return Workflow(
      id: id,
      name: name,
      active: active ?? this.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nodes: nodes,
      lastExecutionStatus: lastExecutionStatus ?? this.lastExecutionStatus,
    );
  }
}
