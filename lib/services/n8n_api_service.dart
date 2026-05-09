import 'dart:convert';
import 'dart:isolate';

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
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            // Receive as plain string so we can parse in an isolate
            responseType: ResponseType.plain,
          ),
        ) {
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Future<List<Workflow>> getWorkflows() async {
    final res = await _dio.get(
      '/workflows',
      queryParameters: {'limit': 250},
    );
    // Parse the large JSON payload in a background isolate to avoid UI jank
    return Isolate.run(() {
      final decoded = jsonDecode(res.data as String) as Map<String, dynamic>;
      final list = decoded['data'] as List<dynamic>;
      return list
          .map((e) => Workflow.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Workflow> setActive(String id, {required bool active}) async {
    // PATCH needs JSON body — use json responseType temporarily
    final patchDio = Dio(BaseOptions(
      baseUrl: _dio.options.baseUrl,
      headers: _dio.options.headers,
      connectTimeout: _dio.options.connectTimeout,
      receiveTimeout: _dio.options.receiveTimeout,
    ));
    final res = await patchDio.patch('/workflows/$id', data: {'active': active});
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
    final decoded = jsonDecode(res.data as String) as Map<String, dynamic>;
    final list = decoded['data'] as List<dynamic>;
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
