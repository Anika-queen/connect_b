import 'dart:async';

import 'package:connect_b/app/theme/app_theme.dart';
import 'package:connect_b/features/chat/domain/entities/message.dart';
import 'package:connect_b/features/chat/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _searchMode = false;
  List<ChatPartner> _searchResults = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (uid != null) {
        ref.read(conversationsProvider.notifier).init(uid);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      final q = value.trim();
      if (q.isEmpty) {
        setState(() { _searchMode = false; _searchResults = const []; });
        return;
      }
      try {
        final client = ref.read(supabaseClientProvider);
        final uid = client.auth.currentUser?.id ?? '';
        final repo = ref.read(chatRepositoryProvider);
        final results = await repo.searchUsers(currentUserId: uid, query: q);
        if (mounted) setState(() { _searchMode = true; _searchResults = results; });
      } catch (_) {}
    });
  }

  Future<void> _open(ChatPartner p) async {
    await Navigator.of(context).pushNamed('/chat/conversation', arguments: p);
    if (mounted) {
      final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
      if (uid != null) ref.read(conversationsProvider.notifier).init(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search by email or name',
              prefixIcon: const Icon(Icons.search, color: AppColors.stone),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.stone),
                      onPressed: () {
                        _searchController.clear();
                        setState(() { _searchMode = false; _searchResults = const []; });
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(child: _searchMode ? _buildSearch() : _buildConversations()),
      ],
    );
  }

  Widget _buildSearch() {
    if (_searchResults.isEmpty) {
      return Center(child: Text('No users found.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.stone)));
    }
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (_, i) {
        final u = _searchResults[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.lightGray, child: Text(_init(u.fullName), style: const TextStyle(color: AppColors.nearBlack, fontWeight: FontWeight.w500))),
            title: Text(u.fullName, style: Theme.of(context).textTheme.bodyMedium),
            subtitle: Text(u.email, style: Theme.of(context).textTheme.bodySmall),
            trailing: const Icon(Icons.chevron_right, color: AppColors.stone),
            onTap: () => _open(u),
          ),
        );
      },
    );
  }

  Widget _buildConversations() {
    final state = ref.watch(conversationsProvider);

    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(state.error!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () {
            final uid = ref.read(supabaseClientProvider).auth.currentUser?.id;
            if (uid != null) ref.read(conversationsProvider.notifier).init(uid);
          }, child: const Text('Retry')),
        ],
      ));
    }
    if (state.conversations.isEmpty) {
      return Center(
        child: Text('No conversations yet.\nSearch above to start chatting.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.stone)),
      );
    }

    return ListView.builder(
      itemCount: state.conversations.length,
      itemBuilder: (_, i) {
        final c = state.conversations[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.lightGray, child: Text(_init(c.partner.fullName), style: const TextStyle(color: AppColors.nearBlack, fontWeight: FontWeight.w500))),
            title: Text(c.partner.fullName, style: Theme.of(context).textTheme.bodyMedium),
            subtitle: Text(c.lastMessage.content, style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(_ago(c.lastMessage.createdAt), style: Theme.of(context).textTheme.labelSmall),
            onTap: () => _open(c.partner),
          ),
        );
      },
    );
  }
}

String _init(String n) => n.trim().isEmpty ? '?' : n.trim()[0].toUpperCase();
String _ago(DateTime dt) {
  final d = DateTime.now().difference(dt);
  if (d.inDays > 0) return '${d.inDays}d';
  if (d.inHours > 0) return '${d.inHours}h';
  if (d.inMinutes > 0) return '${d.inMinutes}m';
  return 'now';
}
