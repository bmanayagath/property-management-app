import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_roles.dart';
import '../../../domain/models/app_user.dart';
import '../../providers/auth_provider.dart';

class AddEditUserScreen extends ConsumerStatefulWidget {
  final AppUser? user;

  const AddEditUserScreen({
    Key? key,
    this.user,
  }) : super(key: key);

  @override
  ConsumerState<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends ConsumerState<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late String _selectedRole;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _uidController.text = user?.id ?? '';
    _emailController.text = user?.username ?? '';
    _selectedRole = user?.role ?? AppRoles.reader;
  }

  @override
  void dispose() {
    _uidController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(authProvider).users;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit User' : 'Add User'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EAF0)),
              ),
              child: Column(
                children: [
                  if (_isEditing) ...[
                    TextFormField(
                      controller: _uidController,
                      enabled: false,
                      decoration: _inputDecoration('Firebase Auth UID'),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email'),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) return 'Email is required';
                      if (!email.contains('@')) {
                        return 'Enter a valid email address';
                      }
                      final duplicate = users.any(
                        (user) =>
                            user.username.toLowerCase() ==
                                email.toLowerCase() &&
                            user.id != widget.user?.id,
                      );
                      if (duplicate) return 'Email already exists';
                      return null;
                    },
                  ),
                  if (!_isEditing) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _inputDecoration('Password'),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) return 'Password is required';
                        if (password.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: _inputDecoration('Confirm Password'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm the password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: _inputDecoration('Role'),
                    items: AppRoles.values
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ),
                        )
                        .toList(),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Role is required'
                        : null,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedRole = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(_isEditing ? 'Update Profile' : 'Create Profile'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFFCFCFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8EAF0)),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authProvider);
    final existing = widget.user;
    final isLastAdmin = existing?.role == AppRoles.admin &&
        _selectedRole != AppRoles.admin &&
        authState.users.where((user) => user.role == AppRoles.admin).length <=
            1;

    if (isLastAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one admin user is required.'),
        ),
      );
      return;
    }

    final user = AppUser(
      id: existing?.id ?? '',
      username: _emailController.text.trim(),
      role: _selectedRole,
      createdAt: existing?.createdAt ?? DateTime.now(),
      updatedAt: existing == null ? null : DateTime.now(),
    );

    final notifier = ref.read(authProvider.notifier);
    var didSave = true;
    if (_isEditing) {
      await notifier.updateUser(user);
    } else {
      didSave = await notifier.addUser(
        user,
        password: _passwordController.text,
      );
    }

    if (!mounted) return;
    if (didSave) {
      Navigator.pop(context);
    } else {
      final message = ref.read(authProvider).errorMessage ??
          'Unable to save user. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
