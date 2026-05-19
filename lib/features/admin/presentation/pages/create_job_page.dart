import 'package:connect_b/features/auth/presentation/providers/auth_provider.dart';
import 'package:connect_b/features/jobs/domain/entities/job_post.dart';
import 'package:connect_b/features/jobs/presentation/providers/jobs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateJobPage extends ConsumerStatefulWidget {
  const CreateJobPage({super.key});

  @override
  ConsumerState<CreateJobPage> createState() => _CreateJobPageState();
}

class _CreateJobPageState extends ConsumerState<CreateJobPage> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  JobPost? _editItem;
  DateTime? _deadline;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is JobPost && _editItem == null) {
      _editItem = arg;
      _titleController.text = arg.title;
      _companyController.text = arg.company;
      _locationController.text = arg.location ?? '';
      _urlController.text = arg.applicationUrl ?? '';
      _deadline = arg.deadline;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool get _isEditing => _editItem != null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: const DatePickerThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    setState(() => _saving = true);
    bool ok;
    if (_isEditing) {
      ok = await ref.read(jobsProvider.notifier).update(
        id: _editItem!.id,
        title: _titleController.text,
        company: _companyController.text,
        location: _locationController.text,
        deadline: _deadline,
        applicationUrl: _urlController.text,
      );
    } else {
      ok = await ref.read(jobsProvider.notifier).create(
        title: _titleController.text,
        company: _companyController.text,
        location: _locationController.text,
        deadline: _deadline,
        applicationUrl: _urlController.text,
      );
    }
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save job.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Job' : 'Create Job')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _field('Job Title', 'Software Engineer', _titleController, validator: (v) {
            if (v == null || v.trim().length < 3) return 'Title must be at least 3 characters.';
            return null;
          }),
          const SizedBox(height: 14),
          _field('Company', 'Google, Meta...', _companyController, validator: (v) {
            if (v == null || v.trim().length < 2) return 'Enter a company name.';
            return null;
          }),
          const SizedBox(height: 14),
          _field('Location (optional)', 'Dhaka, Bangladesh', _locationController),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: TextFormField(
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Deadline (optional)',
                  hintText: 'Select deadline',
                  suffixIcon: Icon(Icons.calendar_today, size: 18, color: Color(0xFFA3A3A3)),
                ),
                controller: TextEditingController(text: _deadline != null ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}' : ''),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _field('Application URL (optional)', 'https://...', _urlController, keyboardType: TextInputType.url),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFFFFF)))
                : Text(_isEditing ? 'Update' : 'Create'),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController c, {String? Function(String?)? validator, TextInputType? keyboardType}) {
    return TextFormField(
      controller: c,
      validator: validator,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
