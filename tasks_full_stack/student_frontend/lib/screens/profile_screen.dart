import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../constants/app_constants.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _themeService = ThemeService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;
  ThemeMode _currentThemeMode = ThemeMode.system;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadInitialTheme();
  }

  Future<void> _loadInitialTheme() async {
    if (mounted) {
      final app = context.findAncestorStateOfType<MyAppState>();
      if (app != null) {
        setState(() {
          _currentThemeMode =
              Theme.of(context).brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light;
        });
      } else {
        await _loadThemeMode();
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUser();
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await _themeService.getThemeMode();
    setState(() {
      _currentThemeMode = themeMode;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await _themeService.setThemeMode(mode);
    setState(() {
      _currentThemeMode = mode;
    });
    if (context.mounted) {
      final appState = context.findAncestorStateOfType<MyAppState>();
      if (appState != null) {
        appState.setThemeMode(mode);
      }
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      try {
        await _authService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildThemeSelector() {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color:
                  _currentThemeMode == ThemeMode.system
                      ? theme.colorScheme.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.brightness_auto,
                color:
                    _currentThemeMode == ThemeMode.system
                        ? selectedColor
                        : unselectedColor,
              ),
              title: const Text('System'),
              selected: _currentThemeMode == ThemeMode.system,
              onTap: () => _setThemeMode(ThemeMode.system),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color:
                  _currentThemeMode == ThemeMode.light
                      ? theme.colorScheme.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.light_mode,
                color:
                    _currentThemeMode == ThemeMode.light
                        ? selectedColor
                        : unselectedColor,
              ),
              title: const Text('Light'),
              selected: _currentThemeMode == ThemeMode.light,
              onTap: () => _setThemeMode(ThemeMode.light),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color:
                  _currentThemeMode == ThemeMode.dark
                      ? theme.colorScheme.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.dark_mode,
                color:
                    _currentThemeMode == ThemeMode.dark
                        ? selectedColor
                        : unselectedColor,
              ),
              title: const Text('Dark'),
              selected: _currentThemeMode == ThemeMode.dark,
              onTap: () => _setThemeMode(ThemeMode.dark),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("My Profile"),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                    ),

                    const SizedBox(height: 22),
                    Divider(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 22),
                    _buildInfoCard(
                      title: 'Name',
                      value: _userData?['name'] ?? 'N/A',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 6),
                    _buildInfoCard(
                      title: 'Email',
                      value: _userData?['email'] ?? 'N/A',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 6),
                    _buildInfoCard(
                      title: 'Registration Number',
                      value: _userData?['registration_number'] ?? 'N/A',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 6),
                    _buildInfoCard(
                      title: 'Role',
                      value:
                          _userData?['role']?.toString().toUpperCase() ?? 'N/A',
                      icon: Icons.assignment_ind_outlined,
                    ),
                    const SizedBox(height: 22),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildThemeSelector(),
                    const SizedBox(height: 22),

                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: Icon(
                            Icons.logout,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
