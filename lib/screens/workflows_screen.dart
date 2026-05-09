import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/workflows_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/metrics_header.dart';
import '../widgets/workflow_card.dart';
import 'settings_screen.dart';
import 'workflow_detail_screen.dart';

class WorkflowsScreen extends ConsumerWidget {
  const WorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // Don't even attempt to load workflows until settings are confirmed present
    if (!settings.hasValue || settings.value == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final workflowsAsync = ref.watch(workflowsProvider);
    final metrics = ref.watch(workflowMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('n8n Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(workflowsProvider.notifier).refresh(),
        child: workflowsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ErrorView(
            message: 'Error: ${err.toString()}',
            onRetry: () => ref.read(workflowsProvider.notifier).refresh(),
          ),
          data: (workflows) {
            if (workflows.isEmpty) {
              return ErrorView(
                message: 'No workflows found.\nCheck your n8n instance has workflows.',
                onRetry: () => ref.read(workflowsProvider.notifier).refresh(),
              );
            }
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: MetricsHeader(metrics: metrics),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final w = workflows[index];
                      return WorkflowCard(
                        workflow: w,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WorkflowDetailScreen(
                              workflowId: w.id,
                              workflowName: w.name,
                            ),
                          ),
                        ),
                        onToggleActive: (val) => ref
                            .read(workflowsProvider.notifier)
                            .toggleActive(w.id, val),
                        onExecute: () =>
                            ref.read(workflowsProvider.notifier).execute(w.id),
                        onDelete: () =>
                            _confirmDelete(context, ref, w.id, w.name),
                      );
                    },
                    childCount: workflows.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workflow'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(workflowsProvider.notifier).delete(id);
    }
  }
}
