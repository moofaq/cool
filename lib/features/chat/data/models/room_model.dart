enum RoomType { public, private, game }

enum RoomStatus { active, inactive, full }

class RoomMember {
  final String userId;
  final String username;
  final String? avatar;
  final bool isModerator;
  final bool isSpeaking;
  final bool isMuted;

  RoomMember({
    required this.userId,
    required this.username,
    this.avatar,
    this.isModerator = false,
    this.isSpeaking = false,
    this.isMuted = false,
  });

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      userId: json['user_id'],
      username: json['username'],
      avatar: json['avatar'],
      isModerator: json['is_moderator'] ?? false,
      isSpeaking: json['is_speaking'] ?? false,
      isMuted: json['is_muted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'avatar': avatar,
      'is_moderator': isModerator,
      'is_speaking': isSpeaking,
      'is_muted': isMuted,
    };
  }
}

class RoomModel {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String ownerId;
  final String ownerName;
  final RoomType type;
  final RoomStatus status;
  final int maxCapacity;
  final List<RoomMember> members;
  final String? gameId;
  final String? password;
  final DateTime createdAt;
  final DateTime updatedAt;

  RoomModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.ownerId,
    required this.ownerName,
    required this.type,
    required this.status,
    required this.maxCapacity,
    required this.members,
    this.gameId,
    this.password,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    List<RoomMember> membersList = [];
    if (json['members'] != null) {
      membersList =
          (json['members'] as List)
              .map((member) => RoomMember.fromJson(member))
              .toList();
    }

    return RoomModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      ownerId: json['owner_id'],
      ownerName: json['owner_name'],
      type: _parseRoomType(json['type']),
      status: _parseRoomStatus(json['status']),
      maxCapacity: json['max_capacity'] ?? 50,
      members: membersList,
      gameId: json['game_id'],
      password: json['password'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static RoomType _parseRoomType(String type) {
    switch (type) {
      case 'public':
        return RoomType.public;
      case 'private':
        return RoomType.private;
      case 'game':
        return RoomType.game;
      default:
        return RoomType.public;
    }
  }

  static RoomStatus _parseRoomStatus(String status) {
    switch (status) {
      case 'active':
        return RoomStatus.active;
      case 'inactive':
        return RoomStatus.inactive;
      case 'full':
        return RoomStatus.full;
      default:
        return RoomStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'max_capacity': maxCapacity,
      'members': members.map((member) => member.toJson()).toList(),
      'game_id': gameId,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  int get memberCount => members.length;
  bool get isFull => memberCount >= maxCapacity;
  bool get isGameRoom => type == RoomType.game;
  bool get isPrivate => type == RoomType.private;
  bool get isPublic => type == RoomType.public;

  bool hasUser(String userId) {
    return members.any((member) => member.userId == userId);
  }

  bool isOwner(String userId) {
    return ownerId == userId;
  }

  bool isModerator(String userId) {
    return members.any(
      (member) => member.userId == userId && member.isModerator,
    );
  }
}
