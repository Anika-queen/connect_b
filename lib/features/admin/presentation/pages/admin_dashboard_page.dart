import 'dart:async';

import 'package:connect_b/app/theme/app_theme.dart';
import 'package:connect_b/features/announcements/domain/entities/announcement.dart';
import 'package:connect_b/features/announcements/presentation/providers/announcements_provider.dart';
import 'package:connect_b/features/jobs/domain/entities/job_post.dart';
import 'package:connect_b/features/jobs/presentation/providers/jobs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';
//shanu : update this
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  bool _loading = true;
  String? _error;

  int _totalUsers = 0;
  int _alumniCount = 0;
  int _jobsCount = 0;
  int _announcementCount = 0;
  List<JobPost> _jobs = const [];
  List<Announcement> _announcements = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(supabaseClientProvider);
      final jobs = ref.read(jobsProvider);
      final anns = ref.read(announcementsProvider);

      final results = await Future.wait<dynamic>([
        client.from('profiles').count(),
        client.from('profiles').count().eq('role', 'alumni'),
        client.from('jobs').count(),
        client.from('announcements').count(),
        Future.value(jobs.jobs),
        Future.value(anns.announcements),
      ]);

      if (!mounted) return;
      setState(() {
        _totalUsers = results[0] as int;
        _alumniCount = results[1] as int;
        _jobsCount = results[2] as int;
        _announcementCount = results[3] as int;
        _jobs = results[4] as List<JobPost>;
        _announcements = results[5] as List<Announcement>;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'Could not load admin data.'; });
    }
  }

  Future<void> _deleteAnnouncement(Announcement item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete announcement?'),
        content: Text('Delete "${item.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    final success = await ref.read(announcementsProvider.notifier).delete(item.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Deleted.' : 'Could not delete.')),
      );
      if (success) _load();
    }
  }

  Future<void> _deleteJob(JobPost item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete job?'),
        content: Text('Delete "${item.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    final success = await ref.read(jobsProvider.notifier).delete(item.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Deleted.' : 'Could not delete.')),
      );
      if (success) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('Retry')),
        ],
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text('Overview', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: [
          _StatCard(label: 'Total Users', value: '$_totalUsers', icon: Icons.people_outline),
          _StatCard(label: 'Alumni', value: '$_alumniCount', icon: Icons.workspace_premium_outlined),
          _StatCard(label: 'Jobs', value: '$_jobsCount', icon: Icons.work_outline),
          _StatCard(label: 'Announcements', value: '$_announcementCount', icon: Icons.campaign_outlined),
        ]),
        const SizedBox(height: 20),
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _ActionButton(icon: Icons.add_rounded, label: 'Create Announcement', onTap: () => _navigate('/admin/announcement/edit')),
        const SizedBox(height: 8),
        _ActionButton(icon: Icons.add_rounded, label: 'Create Job', onTap: () => _navigate('/admin/job/edit')),
        const SizedBox(height: 16),
        Text('All Jobs (${_jobs.length})', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_jobs.isEmpty) _empty('No jobs yet.') else ..._jobs.map(_buildJobCard),
        const SizedBox(height: 16),
        Text('All Announcements (${_announcements.length})', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_announcements.isEmpty) _empty('No announcements yet.') else ..._announcements.map(_buildAnnouncementCard),
      ],
    );
  }

  void _navigate(String route) async {
    final result = await Navigator.of(context).pushNamed<bool?>(route);
    if (result == true && mounted) _load();
  }

  Widget _empty(String msg) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGray)),
    child: Text(msg, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.stone)),
  );

  Widget _buildJobCard(JobPost item) => _card(item.title, item.company, () => _deleteJob(item));
  Widget _buildAnnouncementCard(Announcement item) => _card(item.title, item.details, () => _deleteAnnouncement(item));

  Widget _card(String title, String subtitle, VoidCallback onDelete) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGray)),
    child: Row(
      children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        )),
        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.stone), onPressed: onDelete),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 500 ? 160 : null,
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGray)),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.snow, borderRadius: BorderRadius.circular(9999)),
            child: Icon(icon, size: 20, color: AppColors.nearBlack),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), alignment: Alignment.centerLeft),
      ),
    );
  }
}
