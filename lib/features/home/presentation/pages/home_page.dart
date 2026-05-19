import 'dart:async';

import 'package:connect_b/app/router/app_router.dart';
import 'package:connect_b/app/theme/app_theme.dart';
import 'package:connect_b/core/services/navigation_service.dart';
import 'package:connect_b/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:connect_b/features/chat/presentation/pages/chat_list_page.dart';
import 'package:connect_b/features/directory/domain/entities/alumni_profile.dart';
import 'package:connect_b/features/directory/presentation/providers/directory_provider.dart';
import 'package:connect_b/features/announcements/domain/entities/announcement.dart';
import 'package:connect_b/features/announcements/presentation/providers/announcements_provider.dart';
import 'package:connect_b/features/auth/presentation/providers/auth_provider.dart';
import 'package:connect_b/features/jobs/domain/entities/job_post.dart';
import 'package:connect_b/features/jobs/presentation/providers/jobs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connect_b/core/providers/providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  int _refreshSeed = 0;
  bool? _isAdmin;
  String? _userId;

  static const _baseTabs = ['Home', 'Directory', 'Jobs', 'Announcements', 'Chat'];
  static const _adminTabs = ['Home', 'Directory', 'Jobs', 'Announcements', 'Chat', 'Manage'];

  List<String> get _titles => _isAdmin == true ? _adminTabs : _baseTabs;

  @override
  void initState() {
    super.initState();
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NavigationService.instance.pushReplacementNamed(AppRoutes.login);
      });
      return;
    }
    _userId = currentUser.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null && mounted) {
        setState(() => _isAdmin = user.isAdmin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_titles.length > _selectedIndex ? _titles[_selectedIndex] : ''),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: _openProfileEditor,
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => setState(() => _refreshSeed++),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(child: desktop ? _desktopLayout() : _tabBody()),
      bottomNavigationBar: desktop
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: [
                const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                const NavigationDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: 'Directory'),
                const NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Jobs'),
                const NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: 'Notice'),
                const NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'Chat'),
                if (_isAdmin == true)
                  const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: 'Manage'),
              ],
            ),
    );
  }

  Widget _desktopLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          labelType: NavigationRailLabelType.all,
          destinations: [
            const NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
            const NavigationRailDestination(icon: Icon(Icons.group_outlined), selectedIcon: Icon(Icons.group), label: Text('Directory')),
            const NavigationRailDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: Text('Jobs')),
            const NavigationRailDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign), label: Text('Notice')),
            const NavigationRailDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: Text('Chat')),
            if (_isAdmin == true)
              const NavigationRailDestination(icon: Icon(Icons.admin_panel_settings_outlined), selectedIcon: Icon(Icons.admin_panel_settings), label: Text('Manage')),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: _tabBody()),
      ],
    );
  }

  Widget _tabBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeOverviewTab(refreshSeed: _refreshSeed),
          _DirectoryTab(refreshSeed: _refreshSeed),
          _JobsTab(refreshSeed: _refreshSeed, userId: _userId ?? ''),
          _AnnouncementsTab(refreshSeed: _refreshSeed),
          const ChatListPage(),
          if (_isAdmin == true) const AdminDashboardPage(),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await ref.read(authProvider.notifier).signOut();
    if (mounted) NavigationService.instance.pushReplacementNamed(AppRoutes.login);
  }

  Future<void> _openProfileEditor() async {
    try {
      final updated = await Navigator.of(context).pushNamed<bool?>(AppRoutes.profileEdit);
      if (updated == true && mounted) setState(() => _refreshSeed++);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open profile editor.')));
      }
    }
  }
}

// ── Home Overview Tab ──────────────────────────────────────────

class _HomeOverviewTab extends ConsumerStatefulWidget {
  const _HomeOverviewTab({required this.refreshSeed});
  final int refreshSeed;

  @override
  ConsumerState<_HomeOverviewTab> createState() => _HomeOverviewTabState();
}

class _HomeOverviewTabState extends ConsumerState<_HomeOverviewTab> {
  late Future<_OverviewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _HomeOverviewTab old) {
    super.didUpdateWidget(old);
    if (old.refreshSeed != widget.refreshSeed) _future = _load();
  }

  Future<_OverviewData> _load() async {
    final client = ref.read(supabaseClientProvider);
    final user = ref.read(authProvider).user;
    final jobs = ref.read(jobsProvider);
    final anns = ref.read(announcementsProvider);

    final results = await Future.wait<dynamic>([
      Future.value(user?.fullName),
      client.from('profiles').count().eq('role', 'alumni'),
      client.from('jobs').count(),
      client.from('announcements').count(),
      Future.value(jobs.jobs.take(3).toList()),
      Future.value(anns.announcements.take(3).toList()),
    ]);

    return _OverviewData(
      userName: results[0] as String?,
      alumniCount: results[1] as int,
      jobsCount: results[2] as int,
      announcementCount: results[3] as int,
      jobs: results[4] as List<JobPost>,
      announcements: results[5] as List<Announcement>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_OverviewData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const _ErrorState(message: 'Could not load dashboard data.');
        }
        final d = snap.data!;
        return ListView(
          children: [
            _HeroCard(name: d.userName, alumniCount: d.alumniCount, jobsCount: d.jobsCount, announcementCount: d.announcementCount),
            const SizedBox(height: 16),
            _SectionHeader(title: 'Latest Jobs'),
            const SizedBox(height: 8),
            if (d.jobs.isEmpty) const _EmptyState(message: 'No jobs yet.')
            else ...d.jobs.map((j) => _JobTile(job: j)),
            const SizedBox(height: 12),
            _SectionHeader(title: 'Latest Announcements'),
            const SizedBox(height: 8),
            if (d.announcements.isEmpty) const _EmptyState(message: 'No announcements yet.')
            else ...d.announcements.map((a) => _AnnouncementTile(item: a)),
          ],
        );
      },
    );
  }
}

// ── Directory Tab ──────────────────────────────────────────────

class _DirectoryTab extends ConsumerStatefulWidget {
  const _DirectoryTab({required this.refreshSeed});
  final int refreshSeed;

  @override
  ConsumerState<_DirectoryTab> createState() => _DirectoryTabState();
}

class _DirectoryTabState extends ConsumerState<_DirectoryTab> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(directoryProvider);
    final opts = state.options;

    return Column(
      children: [
        const SizedBox(height: 12),
        if (opts != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterDropdown(label: 'Batch', items: opts.batches, onChanged: (v) => ref.read(directoryProvider.notifier).setBatch(v)),
              _FilterDropdown(label: 'Company', items: opts.companies, onChanged: (v) => ref.read(directoryProvider.notifier).setCompany(v)),
              _FilterDropdown(label: 'Country', items: opts.countries, onChanged: (v) => ref.read(directoryProvider.notifier).setCountry(v)),
              TextButton.icon(
                onPressed: () => ref.read(directoryProvider.notifier).clearFilters(),
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        const SizedBox(height: 10),
        Expanded(
          child: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? _ErrorState(message: state.error!)
                  : state.alumni.isEmpty
                      ? const _EmptyState(message: 'No alumni found.')
                      : ListView.builder(
                          itemCount: state.alumni.length,
                          itemBuilder: (context, i) => _alumniCard(state.alumni[i]),
                        ),
        ),
      ],
    );
  }

  Widget _alumniCard(AlumniProfile alumni) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.lightGray,
              child: Text(_initialOf(alumni.fullName),
                  style: const TextStyle(color: AppColors.nearBlack, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alumni.fullName, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text(alumni.subtitle, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: alumni.email));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email copied')));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(alumni.email,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.stone)),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy, size: 14, color: AppColors.stone),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Jobs Tab ───────────────────────────────────────────────────

class _JobsTab extends ConsumerStatefulWidget {
  const _JobsTab({required this.refreshSeed, required this.userId});
  final int refreshSeed;
  final String userId;

  @override
  ConsumerState<_JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<_JobsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobsProvider.notifier).init(widget.userId);
    });
  }

  @override
  void didUpdateWidget(covariant _JobsTab old) {
    super.didUpdateWidget(old);
    if (old.refreshSeed != widget.refreshSeed) {
      ref.read(jobsProvider.notifier).load();
    }
  }

  void _showMessage(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  void _openApply(JobPost job) async {
    final url = job.applicationUrl?.trim();
    if (url == null || url.isEmpty) {
      _showMessage('No application link.');
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showMessage('Could not open link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobsProvider);

    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return _ErrorState(message: state.error!);
    if (state.jobs.isEmpty) return const _EmptyState(message: 'No jobs posted yet.');

    return ListView(
      children: state.jobs
          .map((j) => _JobTile(
                job: j,
                isSaved: state.savedIds.contains(j.id),
                onApply: () => _openApply(j),
                onToggleSave: () => ref.read(jobsProvider.notifier).toggleSave(j.id),
              ))
          .toList(),
    );
  }
}

// ── Announcements Tab ──────────────────────────────────────────

class _AnnouncementsTab extends ConsumerStatefulWidget {
  const _AnnouncementsTab({required this.refreshSeed});
  final int refreshSeed;

  @override
  ConsumerState<_AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends ConsumerState<_AnnouncementsTab> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(announcementsProvider);

    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return const _ErrorState(message: 'Could not load announcements.');
    if (state.announcements.isEmpty) return const _EmptyState(message: 'No announcements yet.');

    return ListView(
      children: state.announcements.map((a) => _AnnouncementTile(item: a)).toList(),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({this.name, required this.alumniCount, required this.jobsCount, required this.announcementCount});

  final String? name;
  final int alumniCount, jobsCount, announcementCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGray)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome${name?.trim().isNotEmpty == true ? ' $name' : ''}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(label: 'Alumni', value: alumniCount.toString()),
              _StatChip(label: 'Jobs', value: jobsCount.toString()),
              _StatChip(label: 'Notices', value: announcementCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile({required this.job, this.isSaved = false, this.onApply, this.onToggleSave});

  final JobPost job;
  final bool isSaved;
  final VoidCallback? onApply, onToggleSave;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[job.company];
    if (job.location?.trim().isNotEmpty == true) parts.add(job.location!);
    if (job.deadline != null) parts.add('Deadline: ${_formatDate(job.deadline!)}');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: AppColors.snow,
            child: const Icon(Icons.work_outline, color: AppColors.stone, size: 20)),
        title: Text(job.title, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(parts.join(' • '), style: Theme.of(context).textTheme.bodySmall),
        trailing: onApply == null && onToggleSave == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onApply != null)
                    IconButton(tooltip: 'Apply', onPressed: onApply, icon: const Icon(Icons.open_in_new, size: 20)),
                  if (onToggleSave != null)
                    IconButton(
                      tooltip: isSaved ? 'Unsave' : 'Save',
                      onPressed: onToggleSave,
                      icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 20),
                    ),
                ],
              ),
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.item});
  final Announcement item;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[item.details];
    if (item.eventLocation?.trim().isNotEmpty == true) parts.add(item.eventLocation!);
    if (item.eventDate != null) parts.add(_formatDate(item.eventDate!));

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: AppColors.snow,
            child: const Icon(Icons.campaign_outlined, color: AppColors.stone, size: 20)),
        title: Text(item.title, style: Theme.of(context).textTheme.bodyMedium),
        subtitle: Text(parts.join(' • '), style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleLarge);
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({required this.label, required this.items, required this.onChanged});

  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        key: ValueKey(label),
        initialValue: null,
        decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        items: [
          const DropdownMenuItem(value: null, child: Text('All', style: TextStyle(color: AppColors.stone))),
          ...items.map((i) => DropdownMenuItem(value: i, child: Text(i))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.stone)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.stone)),
      );
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(9999), color: AppColors.snow),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: AppColors.pureBlack, fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.stone)),
        ],
      ),
    );
  }
}

class _OverviewData {
  const _OverviewData({
    required this.userName,
    required this.alumniCount,
    required this.jobsCount,
    required this.announcementCount,
    required this.jobs,
    required this.announcements,
  });
  final String? userName;
  final int alumniCount, jobsCount, announcementCount;
  final List<JobPost> jobs;
  final List<Announcement> announcements;
}

String _initialOf(String n) => n.trim().isEmpty ? '?' : n.trim()[0].toUpperCase();

String _formatDate(DateTime dt) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final d = dt.toLocal();
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}
