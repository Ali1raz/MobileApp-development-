import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/search_text_field.dart';
import 'student_details_screen.dart';
import 'add_student_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  _StudentsScreenState createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  // Add search controller and filtered students list
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>>? _filteredStudents;

  // Add focus node
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose(); // Dispose focus node
    super.dispose();
  }

  // Add method to handle keyboard unfocus
  void _handleUnfocus() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  // Add filter method
  void _filterStudents(List<Map<String, dynamic>> students, String query) {
    if (query.isEmpty) {
      setState(() => _filteredStudents = students);
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredStudents =
          students.where((student) {
            final name = student['name'].toString().toLowerCase();
            final regNumber =
                student['registration_number'].toString().toLowerCase();
            return name.contains(lowercaseQuery) ||
                regNumber.contains(lowercaseQuery);
          }).toList();
    });
  }

  Future<void> _fetchStudents() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final studentService =
        Provider.of<AuthProvider>(context, listen: false).studentService;
    try {
      await studentService.fetchStudents();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchStudents,
              textColor: Colors.white,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
              onPressed: _fetchStudents,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => StudentDetailsScreen(
                    registrationNumber: student['registration_number'],
                  ),
            ),
          );
          _fetchStudents();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withAlpha(60),
                    child: Text(
                      (student['name'] ?? '?')[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student['email'] ?? 'No Email',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      student['registration_number'] ?? 'No ID',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList(List<Map<String, dynamic>> students) {
    _filteredStudents ??= students;

    return GestureDetector(
      // Unfocus when tapping outside the search field
      onTap: _handleUnfocus,
      child: Column(
        children: [
          // Add search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchTextField(
              hintText: 'Search by name or registration number',
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: (value) => _filterStudents(students, value),
              onClear: () {
                _searchController.clear();
                _filterStudents(students, '');
                _handleUnfocus();
              },
              onSubmitted: (_) => _handleUnfocus(),
            ),
          ),
          // Student list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchStudents,
              child:
                  _filteredStudents!.isEmpty
                      ? const Center(child: Text('No students found'))
                      : ListView.builder(
                        itemCount: _filteredStudents!.length,
                        itemBuilder:
                            (context, index) =>
                                _buildStudentCard(_filteredStudents![index]),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentService = Provider.of<AuthProvider>(context).studentService;

    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : _buildStudentList(studentService.students!),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStudentScreen()),
          );
          _fetchStudents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
