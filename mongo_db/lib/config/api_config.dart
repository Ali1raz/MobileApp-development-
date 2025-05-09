 class ApiConfig {
  static String baseUrl = 'http://192.168.236.66:4444/api/tasks';

  static void updateBaseUrl({String? host, String? port}) {
    if (host != null || port != null) {
      final uri = Uri.parse(baseUrl);
      final newHost = host ?? uri.host;
      final newPort = port ?? uri.port.toString();
      baseUrl = 'http://$newHost:$newPort/api/tasks';
    }
  }
}