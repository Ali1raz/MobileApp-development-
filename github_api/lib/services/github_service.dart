import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:github_api/models/github_event.dart';
import 'package:github_api/models/github_repo.dart';
import 'package:github_api/models/github_user.dart';
import 'package:github_api/utils/app_errors.dart';

class GithubService {
  static const String baseUrl = 'https://api.github.com';
  static const int perPage = 15;

  Future<GithubUser> fetchUserDetails(String username) async {
    try {
      final url = Uri.parse("$baseUrl/users/$username");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return GithubUser.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw AppError.userNotFound;
      } else {
        throw AppError.unknownError;
      }
    } catch (e) {
      if (e is AppError) rethrow;
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('socket')) {
        throw AppError.networkError;
      }
      throw AppError.unknownError;
    }
  }

  Future<GithubRepo> fetchRepoDetails(String fullName) async {
    try {
      final url = Uri.parse("$baseUrl/repos/$fullName");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return GithubRepo.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw AppError.userNotFound;
      } else {
        throw AppError.unknownError;
      }
    } catch (e) {
      if (e is AppError) rethrow;
      if (e.toString().toLowerCase().contains('network') ||
          e.toString().toLowerCase().contains('socket')) {
        throw AppError.networkError;
      }
      throw AppError.unknownError;
    }
  }

  Future<List<GithubEvent>> fetchUserEvents(
    String username, {
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
        "$baseUrl/users/$username/events?page=$page&per_page=$perPage",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty && page == 1) {
          throw AppError.noActivity;
        }
        return data.map((e) => GithubEvent.fromJson(e)).toList();
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
