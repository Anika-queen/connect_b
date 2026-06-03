class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
// shanu : solve error and update
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: (map['id'] as num).toInt(),
      senderId: map['sender_id'] as String,
      receiverId: map['receiver_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    };
  }
}

class ChatPartner {
  const ChatPartner({
    required this.id,
    required this.fullName,
    required this.email,
  });

  final String id;
  final String fullName;
  final String email;

  factory ChatPartner.fromMap(Map<String, dynamic> map) {
    return ChatPartner(
      id: map['id'] as String,
      fullName: (map['full_name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
    );
  }
}
