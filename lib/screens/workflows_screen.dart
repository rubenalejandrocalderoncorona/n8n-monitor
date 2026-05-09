import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../models/workflow.dart';
import '../services/n8n_api_service.dart';
import '../widgets/error_view.dart';
import '../widgets/metrics_header.dart';
import '../widgets/workflow_card.dart';
import 'settings_screen.dart';
import 'workflow_detail_screen.dart';

class WorkflowsScreen extends StatefulWidget {
  final AppSettings settings;
  final void Function(AppSettings) onSettingsSaved;

  const WorkflowsScreen({
    super.key,
    required this.settings,
    required this.onSettingsSaved,
  });

  @override
  State<WorkflowsScreen> createState() => _WorkflowsScreenState();
}

class _WorkflowsScreenState extends State<WorkflowsScreen> {
  late N8nApiService _api;
  List<Workflow> _workflows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _api = N8nApiService(widget.settings);
    _load();
  }

  @override
  void didUpdateWidget(WorkflowsScreen old) {
    super.didUpdateWidget(old);
    if (old.settings.baseUrl != widget.settings.baseUrl ||
        old.settings.apiKey != widget.settings.apiKey) {
      _api = N8nApiService(widget.settings);
      _load();
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final workflows = await _api.getWorkflows();
      if (!mounted) return;
      setState(() { _workflows = workflows; _loading = false; });
      _enrichInBackground(workflows);
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _enrichInBackground(List<Workflow> workflows) {
    for (var i = 0; i < workflows.length; i++) {
      final idx = i;
      final w = workflows[idx];
      _api.getExecutions(w.id, limit: 1).then((execs) {
        if (!mounted) return;
        if (execs.isEmpty) return;
        setState(() {
          _workflows = List.of(_workflows)..[idx] =
              w.copyWith(lastExecutionStatus: execs.first.status.name);
        });
      }).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('n8n Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SettingsScreen(
                onSaved: (s) {
                  widget.onSettingsSaved(s);
                },
              ),
            )),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_workflows.isEmpty) {
      return ErrorView(message: 'No workflows found.', onRetry: _load);
    }

    final active = _workflows.where((w) => w.active).length;
    final success = _workflows.where((w) => w.lastExecutionStatus == 'success').length;
    final errors = _workflows.where((w) => w.lastExecutionStatus == 'error').length;
    final metrics = (total: _workflows.length, active: active, success: success, errors: errors);

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: MetricsHeader(metrics: metrics)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final w = _workflows[i];
                return WorkflowCard(
                  workflow: w,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => WorkflowDetailScreen(
                      api: _api,
                      workflowId: w.id,
                      workflowName: w.name,
                    ),
                  )),
                  onToggleActive: (val) => _toggleActive(w, val),
                  onExecute: () => _execute(w.id),
                  onDelete: () => _confirmDelete(w.id, w.name),
                );
              },
              childCount: _workflows.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Future<void> _toggleActive(Workflow w, bool val) async {
    try {
      final updated = await _api.setActive(w.id, active: val);
      if (!mounted) return;
      setState(() {
        _workflows = _workflows
            .map((x) => x.id == w.id
                ? updated.copyWith(lastExecutionStatus: w.lastExecutionStatus)
                : x)
            .toList();
      });
    } catch (e) {
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _execute(String id) async {
    try {
      await _api.executeWorkflow(id);
      await Future.delayed(const Duration(seconds: 2));
      _load();
    } catch (e) {
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _confirmDelete(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workflow'),
        content: Text('Delete "$name"? This cannot be undone.'),
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
        await _api.deleteWorkflow(id);
        setState(() => _workflows = _workflows.where((w) => w.id != id).toList());
      } catch (e) {
        if (mounted) _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
