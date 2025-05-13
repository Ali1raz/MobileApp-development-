import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static void updateBaseUrl({String? host, String? port}) {
    if (host != null || port != null) {
      final uri = Uri.parse(baseUrl);
      final newHost = host ?? uri.host;
      final newPort = port ?? uri.port.toString();
      baseUrl = 'http://$newHost:$newPort/api/tasks';
    }
  }
}
