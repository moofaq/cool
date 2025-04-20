enum MessageType { text, gift, system, image }

class MessageModel {
  final String id;
  final String roomId;
  final String? userId;
  final String? username;
  final String? userAvatar;
  final String content;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.roomId,
    this.userId,
    this.username,
    this.userAvatar,
    required this.content,
    required this.type,
    this.metadata,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      roomId: json['room_id'],
      userId: json['user_id'],
      username: json['username'],
      userAvatar: json['user_avatar'],
      content: json['content'],
      type: _parseMessageType(json['type']),
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'gift':
        return MessageType.gift;
      case 'system':
        return MessageType.system;
      case 'image':
        return MessageType.image;
      default:
        return MessageType.text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'username': username,
      'user_avatar': userAvatar,
      'content': content,
      'type': type.toString().split('.').last,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isSystemMessage => type == MessageType.system;
  bool get isUserMessage => type == MessageType.text && userId != null;
  bool get isGiftMessage => type == MessageType.gift;
}
