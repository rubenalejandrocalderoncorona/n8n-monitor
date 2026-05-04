class AppSettings {
  final String baseUrl;
  final String apiKey;

  const AppSettings({required this.baseUrl, required this.apiKey});

  AppSettings.normalized({required String baseUrl, required String apiKey})
      : baseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), ''),
        apiKey = apiKey.trim();
}
