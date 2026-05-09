import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/execution.dart';
import 'api_service_provider.dart';

class ExecutionsNotifier
    extends FamilyAsyncNotifier<List<Execution>, String> {
  @override
  Future<List<Execution>> build(String arg) async {
    final api = ref.watch(apiServiceProvider);
    if (api == null) return [];
    return api.getExecutions(arg);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(arg));
  }

  Future<void> delete(String executionId) async {
    await ref.read(apiServiceProvider)!.deleteExecution(executionId);
    final current = state.value ?? [];
    state = AsyncData(current.where((e) => e.id != executionId).toList());
  }
}

final executionsProvider = AsyncNotifierProviderFamily<ExecutionsNotifier,
    List<Execution>, String>(ExecutionsNotifier.new);
