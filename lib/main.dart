import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/settings_screen.dart';
import 'screens/workflows_screen.dart';

void main() {
  runApp(const ProviderScope(child: N8nMonitorApp()));
}

class N8nMonitorApp extends StatelessWidget {
  const N8nMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'n8n Monitor',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      home: const _HomeGate(),
    );
  }
}

// Stays in the widget tree at all times — reacts to settingsProvider changes.
// When settings go from null → value, it automatically shows WorkflowsScreen.
class _HomeGate extends ConsumerWidget {
  const _HomeGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return settings.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SettingsScreen(isFirstRun: true),
      data: (s) =>
          s == null ? const SettingsScreen(isFirstRun: true) : const WorkflowsScreen(),
    );
  }
}
