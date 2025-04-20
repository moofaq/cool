enum GiftRarity { common, uncommon, rare, epic, legendary }

class GiftModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String? animationUrl;
  final int cost;
  final GiftRarity rarity;
  final bool isLimited;
  final DateTime? expiresAt;

  GiftModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.animationUrl,
    required this.cost,
    required this.rarity,
    this.isLimited = false,
    this.expiresAt,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      animationUrl: json['animation_url'],
      cost: json['cost'],
      rarity: _parseGiftRarity(json['rarity']),
      isLimited: json['is_limited'] ?? false,
      expiresAt:
          json['expires_at'] != null
              ? DateTime.parse(json['expires_at'])
              : null,
    );
  }

  static GiftRarity _parseGiftRarity(String rarity) {
    switch (rarity) {
      case 'common':
        return GiftRarity.common;
      case 'uncommon':
        return GiftRarity.uncommon;
      case 'rare':
        return GiftRarity.rare;
      case 'epic':
        return GiftRarity.epic;
      case 'legendary':
        return GiftRarity.legendary;
      default:
        return GiftRarity.common;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'animation_url': animationUrl,
      'cost': cost,
      'rarity': rarity.toString().split('.').last,
      'is_limited': isLimited,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isAvailable {
    if (!isLimited) return true;
    if (expiresAt == null) return true;
    return expiresAt!.isAfter(DateTime.now());
  }

  String get rarityLabel {
    switch (rarity) {
      case GiftRarity.common:
        return 'عادي';
      case GiftRarity.uncommon:
        return 'غير شائع';
      case GiftRarity.rare:
        return 'نادر';
      case GiftRarity.epic:
        return 'أسطوري';
      case GiftRarity.legendary:
        return 'خارق';
    }
  }
}
