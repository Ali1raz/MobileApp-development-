import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuth;

  const AuthGuard({Key? key, required this.child, this.requireAuth = true})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (requireAuth && !auth.isAuthenticated) {
          return const LoginScreen();
        }

        if (!requireAuth && auth.isAuthenticated) {
          return const LoginScreen();
        }

        return child;
      },
    );
  }
}
