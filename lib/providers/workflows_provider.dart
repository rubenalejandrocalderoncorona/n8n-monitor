import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workflow.dart';
import '../services/n8n_api_service.dart';
import 'api_service_provider.dart';

class WorkflowsNotifier extends AsyncNotifier<List<Workflow>> {
  @override
  Future<List<Workflow>> build() => _fetch();

  Future<List<Workflow>> _fetch() async {
    final api = ref.read(apiServiceProvider);
    if (api == null) return [];

    // Show the list immediately, then enrich with execution status in background
    final workflows = await api.getWorkflows();
    state = AsyncData(workflows);

    _enrichInBackground(api, workflows);
    return workflows;
  }

  void _enrichInBackground(N8nApiService api, List<Workflow> workflows) {
    _throttledEnrich(api, workflows, concurrency: 3).then((enriched) {
      if (state.hasValue) {
        state = AsyncData(enriched);
      }
    }).catchError((_) {});
  }

  Future<List<Workflow>> _throttledEnrich(
    N8nApiService api,
    List<Workflow> workflows, {
    required int concurrency,
  }) async {
    final results = List<Workflow>.of(workflows);
    final semaphore = _Semaphore(concurrency);
    await Future.wait(
      List.generate(workflows.length, (i) async {
        await semaphore.acquire();
        try {
          results[i] = await _enrichWithLastExecution(api, workflows[i]);
          // Emit partial updates so statuses appear as they load
          if (state.hasValue) {
            state = AsyncData(List.of(results));
          }
        } finally {
          semaphore.release();
        }
      }),
    );
    return results;
  }

  Future<Workflow> _enrichWithLastExecution(
      N8nApiService api, Workflow w) async {
    try {
      final execs = await api.getExecutions(w.id, limit: 1);
      if (execs.isEmpty) return w;
      return w.copyWith(lastExecutionStatus: execs.first.status.name);
    } catch (_) {
      return w;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> toggleActive(String id, bool newValue) async {
    final api = ref.read(apiServiceProvider)!;
    final updated = await api.setActive(id, active: newValue);
    final current = state.value ?? [];
    state = AsyncData(
      current
          .map((w) => w.id == id
              ? updated.copyWith(lastExecutionStatus: w.lastExecutionStatus)
              : w)
          .toList(),
    );
  }

  Future<void> delete(String id) async {
    await ref.read(apiServiceProvider)!.deleteWorkflow(id);
    final current = state.value ?? [];
    state = AsyncData(current.where((w) => w.id != id).toList());
  }

  Future<void> execute(String id) async {
    await ref.read(apiServiceProvider)!.executeWorkflow(id);
    await Future.delayed(const Duration(seconds: 2));
    await refresh();
  }
}

final workflowsProvider =
    AsyncNotifierProvider<WorkflowsNotifier, List<Workflow>>(
  WorkflowsNotifier.new,
);

class WorkflowMetrics {
  final int total;
  final int active;
  final int recentSuccess;
  final int recentError;

  const WorkflowMetrics({
    required this.total,
    required this.active,
    required this.recentSuccess,
    required this.recentError,
  });
}

final workflowMetricsProvider = Provider<WorkflowMetrics>((ref) {
  final workflows = ref.watch(workflowsProvider).valueOrNull ?? [];
  return WorkflowMetrics(
    total: workflows.length,
    active: workflows.where((w) => w.active).length,
    recentSuccess:
        workflows.where((w) => w.lastExecutionStatus == 'success').length,
    recentError:
        workflows.where((w) => w.lastExecutionStatus == 'error').length,
  );
});

class _Semaphore {
  final int _max;
  int _current = 0;
  final _queue = <Completer<void>>[];

  _Semaphore(this._max);

  Future<void> acquire() async {
    if (_current < _max) {
      _current++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }

  void release() {
    if (_queue.isNotEmpty) {
      _queue.removeAt(0).complete();
    } else {
      _current--;
    }
  }
}
