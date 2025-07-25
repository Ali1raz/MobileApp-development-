import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../utils/constants.dart';
import '../widgets/ui/brand_text_form_field.dart';
import '../widgets/ui/brand_filled_button.dart';
import '../utils/avatar_utils.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _allUsers = [];
  final List<String> _selectedUserIds = [];
  bool _isLoading = true;
  bool _isCreatingGroup = false;
  bool _isSearching = false;
  String? _groupNameError;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearGroupNameError() {
    if (_groupNameError != null) {
      setState(() {
        _groupNameError = null;
      });
    }
  }

  Future<void> _loadUsers() async {
    try {
      // Only show users with chat history
      final users = await _chatService.getUsersWithLastMessage();
      final usersWithHistory =
          users.where((user) => user['last_message_content'] != null).toList();
      if (mounted) {
        setState(() {
          _users = usersWithHistory;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Something bad happened')));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _allUsers = [];
        _isSearching = false;
      });
      return;
    }
    setState(() {
      _isSearching = true;
    });
    try {
      final allUsers = await _chatService.getUsers();
      setState(() {
        _allUsers = allUsers;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Something bad happened')));
      }
    }
  }

  void _onUserSelected(bool? selected, String userId) {
    setState(() {
      if (selected == true) {
        if (!_selectedUserIds.contains(userId)) {
          _selectedUserIds.add(userId);
        }
      } else {
        _selectedUserIds.remove(userId);
      }
    });
  }

  Future<void> _createGroup() async {
    _clearGroupNameError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final groupName = _groupNameController.text.trim();

    // Validate group name length
    if (groupName.length < 2) {
      setState(() {
        _groupNameError = 'Group name must be at least 2 characters long';
      });
      return;
    }

    if (groupName.length > 50) {
      setState(() {
        _groupNameError = 'Group name must be less than 50 characters';
      });
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member.')),
      );
      return;
    }

    setState(() {
      _isCreatingGroup = true;
    });

    try {
      await _chatService.createGroup(
        name: groupName,
        memberIds: _selectedUserIds,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully!')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating group')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingGroup = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // If searching, filter _allUsers, else filter _users
    final List<Map<String, dynamic>> filteredUsers;
    if (_searchQuery.isNotEmpty) {
      filteredUsers =
          _allUsers.where((user) {
            final username = (user['username'] ?? '').toString().toLowerCase();
            final email = (user['email'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return username.contains(query) || email.contains(query);
          }).toList();
    } else {
      filteredUsers = _users;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Create Group')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: BrandTextFormField(
                        controller: _groupNameController,
                        labelText: 'Group Name',
                        hintText: 'Enter group name',
                        prefixIcon: Icons.group,
                        errorText: _groupNameError,
                        onChanged: (value) => _clearGroupNameError(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a group name';
                          }
                          if (value.trim().length < 2) {
                            return 'Group name must be at least 2 characters long';
                          }
                          if (value.trim().length > 50) {
                            return 'Group name must be less than 50 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Add search field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: BrandTextFormField(
                        controller: _searchController,
                        labelText: 'Search users',
                        hintText: 'Search by username or email',
                        prefixIcon: Icons.search,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _searchUsers(value);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            'Select Members',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_selectedUserIds.length}/${AppConstants.maxMembersAllowed}',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child:
                          _isSearching
                              ? const Center(child: CircularProgressIndicator())
                              : filteredUsers.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 64,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? 'No users to select'
                                          : 'No users found',
                                      style: textTheme.titleMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _searchQuery.isEmpty
                                          ? 'Other users will appear here once they join the app'
                                          : 'Try a different search term',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = filteredUsers[index];
                                  final isSelected = _selectedUserIds.contains(
                                    user['id'],
                                  );
                                  final canSelectMore =
                                      _selectedUserIds.length <
                                      AppConstants.maxMembersAllowed;

                                  return CheckboxListTile(
                                    title: Text(
                                      user['display_name'] ??
                                          user['username'] ??
                                          user['email'] ??
                                          '',
                                    ),
                                    subtitle: Text(
                                      user['username'] ?? user['email'] ?? '',
                                    ),
                                    value: isSelected,
                                    secondary: AvatarUtils.buildUserAvatar(
                                      user['id'],
                                      user['display_name'] ??
                                          user['username'] ??
                                          user['email'] ??
                                          '',
                                      Theme.of(context),
                                      avatarUrl: user['avatar_url'],
                                      radius: 20,
                                      fontSize: 16,
                                    ),
                                    onChanged:
                                        !isSelected && !canSelectMore
                                            ? null
                                            : (bool? selected) {
                                              _onUserSelected(
                                                selected,
                                                user['id'],
                                              );
                                            },
                                  );
                                },
                              ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: 16.0 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: BrandFilledButton(
                        text: 'Create Group',
                        backgroundColor: theme.colorScheme.tertiary,
                        onPressed: _isCreatingGroup ? null : _createGroup,
                        isLoading: _isCreatingGroup,
                        icon: Icons.group_add,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
