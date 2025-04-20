enum GameType { casual, action, puzzle, strategy, card }

class GameModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final GameType type;
  final int minPlayers;
  final int maxPlayers;
  final bool isActive;
  final int? coinReward;
  final int? xpReward;
  final String? unitySceneName;
  final Map<String, dynamic>? gameConfig;

  GameModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.minPlayers,
    required this.maxPlayers,
    this.isActive = true,
    this.coinReward,
    this.xpReward,
    this.unitySceneName,
    this.gameConfig,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      type: _parseGameType(json['type']),
      minPlayers: json['min_players'],
      maxPlayers: json['max_players'],
      isActive: json['is_active'] ?? true,
      coinReward: json['coin_reward'],
      xpReward: json['xp_reward'],
      unitySceneName: json['unity_scene_name'],
      gameConfig: json['game_config'],
    );
  }

  static GameType _parseGameType(String type) {
    switch (type) {
      case 'casual':
        return GameType.casual;
      case 'action':
        return GameType.action;
      case 'puzzle':
        return GameType.puzzle;
      case 'strategy':
        return GameType.strategy;
      case 'card':
        return GameType.card;
      default:
        return GameType.casual;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'type': type.toString().split('.').last,
      'min_players': minPlayers,
      'max_players': maxPlayers,
      'is_active': isActive,
      'coin_reward': coinReward,
      'xp_reward': xpReward,
      'unity_scene_name': unitySceneName,
      'game_config': gameConfig,
    };
  }

  String get typeLabel {
    switch (type) {
      case GameType.casual:
        return 'ترفيهي';
      case GameType.action:
        return 'حركة';
      case GameType.puzzle:
        return 'ألغاز';
      case GameType.strategy:
        return 'استراتيجية';
      case GameType.card:
        return 'ورق';
    }
  }
}
