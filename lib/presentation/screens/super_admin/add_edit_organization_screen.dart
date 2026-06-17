import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/organization_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/organization_provider.dart';

class AddEditOrganizationScreen extends ConsumerStatefulWidget {
  final OrganizationModel? organization;

  const AddEditOrganizationScreen({
    super.key,
    this.organization,
  });

  @override
  ConsumerState<AddEditOrganizationScreen> createState() =>
      _AddEditOrganizationScreenState();
}

class _AddEditOrganizationScreenState
    extends ConsumerState<AddEditOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _addressController;
  late bool _isActive;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final organization = widget.organization;
    _nameController = TextEditingController(text: organization?.name ?? '');
    _contactPersonController =
        TextEditingController(text: organization?.contactPerson ?? '');
    _contactEmailController =
        TextEditingController(text: organization?.contactEmail ?? '');
    _contactPhoneController =
        TextEditingController(text: organization?.contactPhone ?? '');
    _addressController =
        TextEditingController(text: organization?.address ?? '');
    _isActive = organization?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.organization != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Organization' : 'Add Organization'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Organization name',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Organization name is required.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(
                  labelText: 'Contact person',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Contact email',
                  prefixIcon: Icon(Icons.mail_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact phone',
                  prefixIcon: Icon(Icons.call_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: const Text('Active'),
                secondary: const Icon(Icons.verified_rounded),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final currentUser = ref.read(authProvider).currentUser;
    final existing = widget.organization;
    final now = DateTime.now();
    final organization = OrganizationModel(
      id: existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      contactEmail: _contactEmailController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      address: _addressController.text.trim(),
      isActive: _isActive,
      createdAt: existing?.createdAt ?? now,
      createdBy: existing?.createdBy ?? currentUser?.id,
      updatedAt: now,
      updatedBy: currentUser?.id,
    );
    try {
      await ref
          .read(organizationRepositoryProvider)
          .saveOrganization(organization);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
