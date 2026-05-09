import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/execution.dart';
import '../services/n8n_api_service.dart';
import '../widgets/error_view.dart';
import '../widgets/execution_tile.dart';

class WorkflowDetailScreen extends StatefulWidget {
  final N8nApiService api;
  final String workflowId;
  final String workflowName;

  const WorkflowDetailScreen({
    super.key,
    required this.api,
    required this.workflowId,
    required this.workflowName,
  });

  @override
  State<WorkflowDetailScreen> createState() => _WorkflowDetailScreenState();
}

class _WorkflowDetailScreenState extends State<WorkflowDetailScreen> {
  List<Execution> _executions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final execs = await widget.api.getExecutions(widget.workflowId);
      if (!mounted) return;
      setState(() { _executions = execs; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workflowName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kRed),
            tooltip: 'Delete workflow',
            onPressed: _confirmDeleteWorkflow,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_executions.isEmpty) {
      return ErrorView(message: 'No executions yet.', onRetry: _load);
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _executions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => ExecutionTile(
          execution: _executions[i],
          onDelete: () => _deleteExecution(_executions[i].id),
        ),
      ),
    );
  }

  Future<void> _deleteExecution(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Execution'),
        content: const Text('Remove this execution record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.api.deleteExecution(id);
        setState(() => _executions = _executions.where((e) => e.id != id).toList());
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  Future<void> _confirmDeleteWorkflow() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workflow'),
        content: Text('Delete "${widget.workflowName}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await widget.api.deleteWorkflow(widget.workflowId);
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }
}
