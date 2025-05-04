import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:github_api/utils/app_errors.dart';

class GithubService {
  static const String baseUrl = 'https://api.github.com';

  Future<List<dynamic>> fetchUserEvents(String username) async {
    try {
      final url = Uri.parse("$baseUrl/users/$username/events");
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          throw AppError.noActivity;
        }
        return data;
      } else if (response.statusCode == 404) {
        throw AppError.userNotFound;
      } else {
        throw AppError.unknownError;
      }
    } on AppError {
      rethrow;
    } catch (e) {
      if (e.toString().toLowerCase().contains('network') || 
          e.toString().toLowerCase().contains('socket')) {
        throw AppError.networkError;
      }
      throw AppError.unknownError;
    }
  }
} 