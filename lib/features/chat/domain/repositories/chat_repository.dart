import 'package:connect_b/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  Future<List<ChatPartner>> searchUsers({
    required String currentUserId,
    String query,
    int limit,
  });
  Future<List<Message>> fetchMessages({
    required String currentUserId,
    required String partnerId,
    int limit,
  });
  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  });
  Future<List<({ChatPartner partner, Message lastMessage, int messageCount})>>
      fetchConversations(String currentUserId);
}
