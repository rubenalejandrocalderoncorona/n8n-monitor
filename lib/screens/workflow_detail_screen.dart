import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/executions_provider.dart';
import '../providers/workflows_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/execution_tile.dart';
import '../app_theme.dart';

class WorkflowDetailScreen extends ConsumerWidget {
  final String workflowId;
  final String workflowName;

  const WorkflowDetailScreen({
    super.key,
    required this.workflowId,
    required this.workflowName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final executionsAsync = ref.watch(executionsProvider(workflowId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          workflowName,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kRed),
            tooltip: 'Delete workflow',
            onPressed: () =>
                _confirmDeleteWorkflow(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(executionsProvider(workflowId).notifier).refresh(),
        child: executionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ErrorView(
            message: err.toString(),
            onRetry: () => ref
                .read(executionsProvider(workflowId).notifier)
                .refresh(),
          ),
          data: (executions) {
            if (executions.isEmpty) {
              return const ErrorView(message: 'No executions yet');
            }
            return ListView.separated(
              itemCount: executions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final e = executions[index];
                return ExecutionTile(
                  execution: e,
                  onDelete: () => _confirmDeleteExecution(context, ref, e.id),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteExecution(
      BuildContext context, WidgetRef ref, String executionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Execution'),
        content: const Text('Remove this execution record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(executionsProvider(workflowId).notifier)
          .delete(executionId);
    }
  }

  Future<void> _confirmDeleteWorkflow(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workflow'),
        content: Text('Delete "$workflowName"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(workflowsProvider.notifier).delete(workflowId);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
