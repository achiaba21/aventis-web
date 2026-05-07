class UserFavorite {
  final int apartId;
  final DateTime createdAt;

  UserFavorite({
    required this.apartId,
    required this.createdAt,
  });

  UserFavorite.fromJson(Map<String, dynamic> json)
      : apartId = json['apartId'] ?? json['apartment_id'] ?? json['appartement_id'],
        createdAt = json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'apartId': apartId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserFavorite && other.apartId == apartId;
  }

  @override
  int get hashCode => apartId.hashCode;

  @override
  String toString() {
    return 'UserFavorite(apartId: $apartId, createdAt: $createdAt)';
  }
}