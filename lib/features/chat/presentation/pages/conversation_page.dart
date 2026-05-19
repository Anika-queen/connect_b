import 'package:connect_b/app/theme/app_theme.dart';
import 'package:connect_b/features/chat/domain/entities/message.dart';
import 'package:connect_b/features/chat/presentation/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';

class ConversationPage extends ConsumerStatefulWidget {
  const ConversationPage({super.key});

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  ChatPartner? _partner;
  String _userId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ChatPartner && _partner == null) {
      _partner = arg;
      _userId = ref.read(supabaseClientProvider).auth.currentUser?.id ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(messagesProvider.notifier).init(_userId, arg.id);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _partner == null) return;
    _messageController.clear();

    final ok = await ref.read(messagesProvider.notifier).send(text);
    if (ok) _scrollBottom();
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not send message.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundColor: AppColors.lightGray, radius: 16,
              child: Text(_init(_partner?.fullName ?? '?'), style: const TextStyle(color: AppColors.nearBlack, fontWeight: FontWeight.w500, fontSize: 14)),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_partner?.fullName ?? 'Chat', style: Theme.of(context).textTheme.titleMedium),
              Text(_partner?.email ?? '', style: Theme.of(context).textTheme.labelSmall),
            ]),
          ],
        ),
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Expanded(
                child: state.messages.isEmpty
                    ? Center(child: Text('No messages yet.\nSay hello!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.stone)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: state.messages.length,
                        itemBuilder: (_, i) => _bubble(state.messages[i]),
                      ),
              ),
              _buildInput(),
            ]),
    );
  }

  Widget _bubble(Message msg) {
    final mine = msg.senderId == _userId;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.lightGray : AppColors.snow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: mine ? const Radius.circular(12) : Radius.zero,
            bottomRight: mine ? Radius.zero : const Radius.circular(12),
          ),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg.content, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(_time(msg.createdAt), style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.lightGray))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: Theme.of(context).textTheme.bodyMedium,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _send,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16), minimumSize: const Size(48, 48)),
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

String _init(String n) => n.trim().isEmpty ? '?' : n.trim()[0].toUpperCase();
String _time(DateTime dt) {
  final d = dt.toLocal();
  return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
