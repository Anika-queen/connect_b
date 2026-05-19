import 'package:connect_b/app/theme/app_theme.dart';
import 'package:connect_b/features/auth/domain/entities/user.dart';
import 'package:connect_b/features/auth/presentation/providers/auth_provider.dart';
import 'package:connect_b/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _batchController = TextEditingController();
  final _companyController = TextEditingController();
  final _countryController = TextEditingController();
  final _expertiseController = TextEditingController();
  bool _saving = false;

  AppUser? get _user => ref.read(authProvider).user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fill());
  }

  void _fill() {
    final u = _user;
    if (u == null) return;
    _fullNameController.text = u.fullName;
    _departmentController.text = u.department ?? '';
    _batchController.text = u.batch ?? '';
    _companyController.text = u.company ?? '';
    _countryController.text = u.country ?? '';
    _expertiseController.text = u.expertise ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _departmentController.dispose();
    _batchController.dispose();
    _companyController.dispose();
    _countryController.dispose();
    _expertiseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final u = _user;
    if (u == null) return;

    setState(() => _saving = true);
    try {
      await ref.read(profileProvider.notifier).update(
            userId: u.id,
            fullName: _fullNameController.text,
            department: _departmentController.text,
            batch: _batchController.text,
            company: _companyController.text,
            country: _countryController.text,
            expertise: _expertiseController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update profile.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = _user;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: u == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.snow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${u.email}',
                            style: Theme.of(context).textTheme.bodyMedium),
                        Text('Role: ${_cap(u.role)}',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _field('Full Name', 'Your full name', _fullNameController, validator: (v) {
                    if (v == null || v.trim().length < 2) return 'Enter valid name.';
                    return null;
                  }),
                  const SizedBox(height: 12),
                  _field('Department', 'CSE, EEE...', _departmentController, validator: (v) {
                    if (v == null || v.trim().length < 2) return 'Enter department.';
                    return null;
                  }),
                  const SizedBox(height: 12),
                  _field('Batch', '2019', _batchController, keyboardType: TextInputType.number, validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter batch.';
                    return null;
                  }),
                  const SizedBox(height: 12),
                  _field('Company (Optional)', 'Company name', _companyController),
                  const SizedBox(height: 12),
                  _field('Country (Optional)', 'Bangladesh', _countryController),
                  const SizedBox(height: 12),
                  _field('Expertise (Optional)', 'Mobile Development...', _expertiseController, maxLines: 3),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.pureWhite),
                          )
                        : const Text('Save Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, String hint, TextEditingController c,
      {String? Function(String?)? validator, TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

String _cap(String v) => v.isEmpty ? v : '${v[0].toUpperCase()}${v.substring(1)}';
