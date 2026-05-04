import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/n8n_api_service.dart';
import 'settings_provider.dart';

final apiServiceProvider = Provider<N8nApiService?>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings == null) return null;
  return N8nApiService(settings);
});
