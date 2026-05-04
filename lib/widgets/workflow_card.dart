import 'package:flutter/material.dart';
import '../models/workflow.dart';
import 'status_badge.dart';
import 'status_chip.dart';
import '../app_theme.dart';

class WorkflowCard extends StatelessWidget {
  final Workflow workflow;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onExecute;
  final VoidCallback onDelete;

  const WorkflowCard({
    super.key,
    required this.workflow,
    required this.onTap,
    required this.onToggleActive,
    required this.onExecute,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workflow.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: kOnSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(active: workflow.active),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusChip(statusName: workflow.lastExecutionStatus),
                  const Spacer(),
                  if (workflow.isManuallyTriggerable)
                    IconButton(
                      icon: const Icon(Icons.play_circle_outline,
                          color: kOrange, size: 22),
                      tooltip: 'Run now',
                      visualDensity: VisualDensity.compact,
                      onPressed: onExecute,
                    ),
                  Switch(
                    value: workflow.active,
                    onChanged: onToggleActive,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.delete_outline, color: kGrey, size: 20),
                    tooltip: 'Delete workflow',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
