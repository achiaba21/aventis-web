import 'package:hive/hive.dart';
import 'package:web_flutter/model/user/user.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 1)
class ChatMessage extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  User? expediteur;

  @HiveField(2)
  String? contenu;

  @HiveField(3)
  DateTime? createdAt;

  @HiveField(4)
  int? conversationId;

  @HiveField(5)
  bool? isRead;

  @HiveField(6)
  bool? isSending;

  @HiveField(7)
  bool? hasFailed;

  @HiveField(8)
  String? tempId;

  ChatMessage({
    this.id,
    this.expediteur,
    this.contenu,
    this.createdAt,
    this.conversationId,
    this.isRead,
    this.isSending,
    this.hasFailed,
    this.tempId,
  });

  static ChatMessage fromJsonAll(Map<String, dynamic> json) {
    return ChatMessage.fromJson(json);
  }

  ChatMessage.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    expediteur = json['client'] != null || json['expediteur'] != null
        ? User.fromJsonAll(json['client'] ?? json['expediteur'])
        : null;

    contenu = json['contenu'];

    createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now();

    conversationId = json['conversationId'] ?? json['seanceId'];
    isRead = json['isRead'] ?? false;
    isSending = json['isSending'] ?? false;
    hasFailed = json['hasFailed'] ?? false;
    tempId = json['tempId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;

    if (expediteur != null) {
      data['client'] = expediteur!.toJson();
      data['expediteur'] = expediteur!.toJson();
    }

    data['contenu'] = contenu;
    data['createdAt'] = createdAt?.toIso8601String();
    data['conversationId'] = conversationId;
    data['seanceId'] = conversationId; // Pour compatibilité serveur
    data['isRead'] = isRead;
    data['isSending'] = isSending;
    data['hasFailed'] = hasFailed;
    data['tempId'] = tempId;

    return data;
  }

  bool get isFromCurrentUser {
    // Cette méthode sera surchargée dans le service pour comparer avec l'utilisateur connecté
    return false;
  }

  String get timeDisplay {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${createdAt!.day}/${createdAt!.month}';
    }
  }

  ChatMessage copyWith({
    int? id,
    User? expediteur,
    String? contenu,
    DateTime? createdAt,
    int? conversationId,
    bool? isRead,
    bool? isSending,
    bool? hasFailed,
    String? tempId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      expediteur: expediteur ?? this.expediteur,
      contenu: contenu ?? this.contenu,
      createdAt: createdAt ?? this.createdAt,
      conversationId: conversationId ?? this.conversationId,
      isRead: isRead ?? this.isRead,
      isSending: isSending ?? this.isSending,
      hasFailed: hasFailed ?? this.hasFailed,
      tempId: tempId ?? this.tempId,
    );
  }

  @override
  String toString() {
    return toJson().toString();
  }
}