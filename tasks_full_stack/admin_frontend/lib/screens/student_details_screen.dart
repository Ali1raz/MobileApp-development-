import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_student_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String registrationNumber;

  const StudentDetailsScreen({super.key, required this.registrationNumber});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _studentData;

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final studentService =
          Provider.of<AuthProvider>(context, listen: false).studentService;
      _studentData = await studentService.getStudent(widget.registrationNumber);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Student'),
            content: const Text(
              'Are you sure you want to delete this student? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      try {
        final studentService =
            Provider.of<AuthProvider>(context, listen: false).studentService;
        await studentService.deleteStudent(widget.registrationNumber);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student deleted successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting student: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchStudentDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails() {
    if (_studentData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Text(
                          (_studentData!['name'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _studentData!['name'] ?? 'No Name',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _studentData!['registration_number'] ?? 'No ID',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    Icons.email_outlined,
                    'Email',
                    _studentData!['email'] ?? 'No Email',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Member Since',
                    _studentData!['created_at'] != null
                        ? DateTime.parse(
                          _studentData!['created_at'],
                        ).toString().split(' ')[0]
                        : 'Unknown',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditStudentScreen(
                              registrationNumber: widget.registrationNumber,
                              studentData: _studentData!,
                            ),
                      ),
                    );
                    if (result == true && mounted) {
                      _fetchStudentDetails();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showDeleteConfirmation,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Details')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : _buildStudentDetails(),
    );
  }
}
