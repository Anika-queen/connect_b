import 'package:connect_b/features/chat/domain/entities/message.dart';
import 'package:connect_b/features/chat/domain/repositories/chat_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//lisa: it
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ChatPartner>> searchUsers({
    required String currentUserId,
    String query = '',
    int limit = 30,
  }) async {
    final cleaned = query.trim().toLowerCase();
    var req = _client
        .from('profiles')
        .select('id, full_name, email')
        .neq('id', currentUserId);

    if (cleaned.isNotEmpty) {
      final safe = _sanitize(cleaned);
      req = req.or('email.ilike.*$safe*,full_name.ilike.*$safe*');
    }

    final response = await req.order('full_name').limit(limit);
    return (response as List<dynamic>)
        .map((r) => ChatPartner.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Message>> fetchMessages({
    required String currentUserId,
    required String partnerId,
    int limit = 60,
  }) async {
    final response = await _client
        .from('messages')
        .select('id, sender_id, receiver_id, content, created_at')
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
        .or('sender_id.eq.$partnerId,receiver_id.eq.$partnerId')
        .order('created_at', ascending: true)
        .limit(limit);

    return (response as List<dynamic>)
        .map((r) => Message.fromMap(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final data = await _client.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content.trim(),
    }).select('id, sender_id, receiver_id, content, created_at').single();

    return Message.fromMap(data);
  }

  @override
  Future<List<({ChatPartner partner, Message lastMessage, int messageCount})>>
      fetchConversations(String currentUserId) async {
    final response = await _client
        .from('messages')
        .select('id, sender_id, receiver_id, content, created_at')
        .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
        .order('created_at', ascending: false)
        .limit(200);

    final messages = (response as List<dynamic>)
        .map((r) => Message.fromMap(r as Map<String, dynamic>))
        .toList();

    if (messages.isEmpty) return const [];

    final Map<String, List<Message>> grouped = {};
    for (final msg in messages) {
      final pid = msg.senderId == currentUserId ? msg.receiverId : msg.senderId;
      grouped.putIfAbsent(pid, () => []).add(msg);
    }

    final pids = grouped.keys.toList();
    final profiles = await _client
        .from('profiles')
        .select('id, full_name, email')
        .inFilter('id', pids);

    final pmap = {
      for (final p in (profiles as List<dynamic>))
        (p as Map<String, dynamic>)['id'] as String: ChatPartner.fromMap(p),
    };

    final convs = <({ChatPartner partner, Message lastMessage, int messageCount})>[];
    for (final e in grouped.entries) {
      final partner = pmap[e.key];
      if (partner == null) continue;
      convs.add((
        partner: partner,
        lastMessage: e.value.first,
        messageCount: e.value.length,
      ));
    }

    convs.sort(
      (a, b) => b.lastMessage.createdAt.compareTo(a.lastMessage.createdAt),
    );
    return convs;
  }

  String _sanitize(String input) {
    return input
        .replaceAll(',', ' ')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('%', '')
        .replaceAll('*', '');
  }
}
