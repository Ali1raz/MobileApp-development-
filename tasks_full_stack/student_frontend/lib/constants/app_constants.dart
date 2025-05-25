class AppConstants {
  // API Endpoints
  static const String loginEndpoint = 'student/login';
  static const String logoutEndpoint = 'student/logout';

  // this is your machine ip where you serving (laravel) api app for physical android
  static const String baseUrl = 'http://192.168.213.66:8000/api';

  static const String tokenKey = 'token';
  static const String userKey = 'user';

  // Routes
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
}
