class AuthService {
  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (email == 'admin@example.com' && password == '12345678') {
      return true;
    }
    throw Exception('Invalid email or password');
  }
}
