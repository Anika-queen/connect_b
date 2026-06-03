import 'dart:async';
// lisa updates
import 'package:connect_b/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:connect_b/features/chat/domain/entities/message.dart';
import 'package:connect_b/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connect_b/core/providers/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.read(supabaseClientProvider));
});

// ── Search users provider ──────────────────────────────────────

final searchUsersProvider = FutureProvider.autoDispose
    .family<List<ChatPartner>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  final client = ref.read(supabaseClientProvider);
  final userId = client.auth.currentUser?.id ?? '';
  final repo = ref.read(chatRepositoryProvider);
  return repo.searchUsers(currentUserId: userId, query: query);
});

// ── Conversations provider ─────────────────────────────────────

class ConversationsState {
  const ConversationsState({
    this.conversations = const [],
    this.loading = false,
    this.error,
  });

  final List<({
    ChatPartner partner,
    Message lastMessage,
    int messageCount,
  })> conversations;
  final bool loading;
  final String? error;

  ConversationsState copyWith({
    List<({
      ChatPartner partner,
      Message lastMessage,
      int messageCount,
    })>? conversations,
    bool? loading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  ConversationsNotifier(this._repo) : super(const ConversationsState());

  final ChatRepository _repo;
  String? _userId;

  void init(String userId) {
    _userId = userId;
    load();
  }

  Future<void> load() async {
    if (_userId == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final convs = await _repo.fetchConversations(_userId!);
      state = ConversationsState(conversations: convs);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Could not load conversations.',
      );
    }
  }
}

final conversationsProvider =
    StateNotifierProvider.autoDispose<ConversationsNotifier, ConversationsState>(
  (ref) => ConversationsNotifier(ref.read(chatRepositoryProvider)),
);

// ── Messages provider (per conversation) ───────────────────────

class MessagesState {
  const MessagesState({
    this.messages = const [],
    this.loading = false,
    this.error,
  });

  final List<Message> messages;
  final bool loading;
  final String? error;

  MessagesState copyWith({
    List<Message>? messages,
    bool? loading,
    String? error,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier(this._repo, this._client)
      : super(const MessagesState());

  final ChatRepository _repo;
  final SupabaseClient _client;
  String? _userId;
  String? _partnerId;
  RealtimeChannel? _channel;

  void init(String userId, String partnerId) {
    _userId = userId;
    _partnerId = partnerId;
    _loadMessages();
    _subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_userId == null || _partnerId == null) return;
    _channel = _client
        .channel('chat_${_partnerId}_$_userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            final data = payload.newRecord;
            final sid = data['sender_id'] as String;
            if (sid == _partnerId || sid == _userId) {
              final msg = Message(
                id: (data['id'] as num).toInt(),
                senderId: sid,
                receiverId: data['receiver_id'] as String,
                content: data['content'] as String,
                createdAt: DateTime.parse(data['created_at'] as String),
              );
              if (state.messages.any((m) => m.id == msg.id)) return;
              state = state.copyWith(messages: [...state.messages, msg]);
            }
          },
        )
        .subscribe();
  }

  Future<void> _loadMessages() async {
    if (_userId == null || _partnerId == null) return;
    state = state.copyWith(loading: true, error: null);
    try {
      final msgs = await _repo.fetchMessages(
        currentUserId: _userId!,
        partnerId: _partnerId!,
      );
      state = MessagesState(messages: msgs);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Could not load messages.',
      );
    }
  }

  Future<bool> send(String content) async {
    if (_userId == null || _partnerId == null) return false;
    try {
      final msg = await _repo.sendMessage(
        senderId: _userId!,
        receiverId: _partnerId!,
        content: content,
      );
      state = state.copyWith(messages: [...state.messages, msg]);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final messagesProvider =
    StateNotifierProvider.autoDispose<MessagesNotifier, MessagesState>(
  (ref) => MessagesNotifier(
    ref.read(chatRepositoryProvider),
    ref.read(supabaseClientProvider),
  ),
);
