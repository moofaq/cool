class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final String? bio;
  final int level;
  final int xp;
  final int coins;
  final int gems;
  final int followersCount;
  final int followingCount;
  final bool isOnline;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
    required this.level,
    required this.xp,
    required this.coins,
    required this.gems,
    required this.followersCount,
    required this.followingCount,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatar: json['avatar'],
      bio: json['bio'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'level': level,
      'xp': xp,
      'coins': coins,
      'gems': gems,
      'followers_count': followersCount,
      'following_count': followingCount,
      'is_online': isOnline,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    String? bio,
    int? level,
    int? xp,
    int? coins,
    int? gems,
    int? followersCount,
    int? followingCount,
    bool? isOnline,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
