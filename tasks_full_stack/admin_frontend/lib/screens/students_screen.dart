import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode, // Add focus node
              decoration: InputDecoration(
                hintText: 'Search by name or registration number',
                prefixIcon: const Icon(Icons.search),
                // Add clear button when text is entered
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterStudents(students, '');
                            _handleUnfocus();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => _filterStudents(students, value),
              // Add keyboard actions
              textInputAction: TextInputAction.search,
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
                        itemBuilder: (context, index) {
                          final student = _filteredStudents![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  (student['name'] ?? '?')[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(student['name'] ?? 'No Name'),
                              subtitle: Text(student['email'] ?? 'No Email'),
                              trailing: Text(
                                student['registration_number'] ?? 'No ID',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => StudentDetailsScreen(
                                          registrationNumber:
                                              student['registration_number'],
                                        ),
                                  ),
                                );
                                _fetchStudents();
                              },
                            ),
                          );
                        },
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
