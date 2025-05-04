enum AppError {
  userNotFound('User not found. Please check the username and try again.'),
  networkError('Network error. Please check your internet connection and try again.'),
  noActivity('No activity found for this user.'),
  unknownError('Something went wrong. Please try again later.');

  final String message;
  const AppError(this.message);

  static AppError fromException(Exception e) {
    final message = e.toString().toLowerCase();
    if (message.contains('user not found')) {
      return AppError.userNotFound;
    } else if (message.contains('network') || message.contains('socket')) {
      return AppError.networkError;
    } else {
      return AppError.unknownError;
    }
  }
} 