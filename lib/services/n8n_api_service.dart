import 'package:dio/dio.dart';
import '../models/execution.dart';
import '../models/settings.dart';
import '../models/workflow.dart';

class N8nApiException implements Exception {
  final int? statusCode;
  final String message;

  const N8nApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class N8nApiService {
  final Dio _dio;

  N8nApiService(AppSettings settings)
      : _dio = Dio(
          BaseOptions(
            baseUrl: '${settings.baseUrl}/api/v1',
            headers: {'X-N8N-API-KEY': settings.apiKey},
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        ) {
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Future<List<Workflow>> getWorkflows() async {
    final res = await _dio.get(
      '/workflows',
      queryParameters: {'excludePinnedData': true, 'limit': 250},
    );
    final list = res.data['data'] as List<dynamic>;
    return list
        .map((e) => Workflow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Workflow> setActive(String id, {required bool active}) async {
    final res =
        await _dio.patch('/workflows/$id', data: {'active': active});
    return Workflow.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteWorkflow(String id) async {
    await _dio.delete('/workflows/$id');
  }

  Future<void> executeWorkflow(String id) async {
    await _dio.post('/workflows/$id/execute');
  }

  Future<List<Execution>> getExecutions(String workflowId,
      {int limit = 25}) async {
    final res = await _dio.get(
      '/executions',
      queryParameters: {
        'workflowId': workflowId,
        'limit': limit,
        'includeData': false,
      },
    );
    final list = res.data['data'] as List<dynamic>;
    return list
        .map((e) => Execution.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteExecution(String id) async {
    await _dio.delete('/executions/$id');
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final status = err.response?.statusCode;
    final message = switch (status) {
      401 => 'Invalid API key',
      403 => 'Forbidden — check key permissions',
      404 => 'Resource not found',
      _ => err.message ?? 'Network error',
    };
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: N8nApiException(message, statusCode: status),
        type: err.type,
      ),
    );
  }
}
