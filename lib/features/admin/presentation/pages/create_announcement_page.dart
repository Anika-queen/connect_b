import 'package:connect_b/features/announcements/domain/entities/announcement.dart';
import 'package:connect_b/features/announcements/presentation/providers/announcements_provider.dart';
import 'package:connect_b/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateAnnouncementPage extends ConsumerStatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  ConsumerState<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends ConsumerState<CreateAnnouncementPage> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Announcement? _editItem;
  DateTime? _eventDate;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Announcement && _editItem == null) {
      _editItem = arg;
      _titleController.text = arg.title;
      _detailsController.text = arg.details;
      _locationController.text = arg.eventLocation ?? '';
      _eventDate = arg.eventDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool get _isEditing => _editItem != null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: const DatePickerThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    setState(() => _saving = true);
    bool ok;
    if (_isEditing) {
      ok = await ref.read(announcementsProvider.notifier).update(
        id: _editItem!.id,
        title: _titleController.text,
        details: _detailsController.text,
        eventLocation: _locationController.text,
        eventDate: _eventDate,
      );
    } else {
      ok = await ref.read(announcementsProvider.notifier).create(
        title: _titleController.text,
        details: _detailsController.text,
        eventLocation: _locationController.text,
        eventDate: _eventDate,
        createdBy: userId,
      );
    }
    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save announcement.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Announcement' : 'Create Announcement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field('Title', 'Seminar on AI', _titleController, validator: (v) {
              if (v == null || v.trim().length < 3) return 'Title must be at least 3 characters.';
              return null;
            }),
            const SizedBox(height: 14),
            _field('Details', 'Describe the event...', _detailsController, validator: (v) {
              if (v == null || v.trim().length < 5) return 'Details must be at least 5 characters.';
              return null;
            }, maxLines: 4),
            const SizedBox(height: 14),
            _field('Event Location (optional)', 'Room 301, CSE Building', _locationController),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Event Date (optional)',
                    hintText: 'Select date',
                    suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFFA3A3A3)),
                  ),
                  controller: TextEditingController(
                    text: _eventDate != null ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}' : '',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFFFFF)))
                  : Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController c, {String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: c,
      validator: validator,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
