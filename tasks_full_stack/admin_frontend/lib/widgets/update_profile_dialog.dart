import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UpdateProfileDialog extends StatelessWidget {
  final String type;
  final String currentValue;

  const UpdateProfileDialog({
    super.key,
    required this.type,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Update ${type[0].toUpperCase() + type.substring(1)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildUpdateForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: currentValue);
    final confirmController =
        type == 'password' ? TextEditingController() : null;
    bool isLoading = false;
    String? errorMessage;

    return StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: type == 'password' ? 'New Password' : 'New $type',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    type == 'email'
                        ? Icons.email_outlined
                        : type == 'name'
                        ? Icons.person_outline
                        : Icons.lock_outline,
                  ),
                ),
                obscureText: type == 'password',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a value';
                  }
                  if (type == 'email' &&
                      (!value.contains('@') || !value.contains('.'))) {
                    return 'Please enter a valid email';
                  }
                  if (type == 'password' && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              if (type == 'password') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != controller.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () async {
                          if (!formKey.currentState!.validate()) return;

                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          try {
                            final auth = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            await auth.updateProfile(
                              type == 'name'
                                  ? controller.text
                                  : auth.userData?['name'] ?? '',
                              type == 'email'
                                  ? controller.text
                                  : auth.userData?['email'] ?? '',
                              type == 'password' ? controller.text : null,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context, true);
                            }
                          } catch (e) {
                            setState(() {
                              errorMessage = e.toString();
                            });
                          } finally {
                            if (context.mounted) {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }
}
