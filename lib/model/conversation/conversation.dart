import 'package:hive/hive.dart';
import 'package:web_flutter/model/conversation/chat_message.dart';
import 'package:web_flutter/model/user/user.dart';

part 'conversation.g.dart';

@HiveType(typeId: 0)
class Conversation extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  User? proprietaire;

  @HiveField(2)
  User? locataire;

  @HiveField(3)
  DateTime? dateDebut;

  @HiveField(4)
  DateTime? dateFin;

  @HiveField(5)
  bool? active;

  @HiveField(6)
  int? bookingId;

  @HiveField(7)
  List<ChatMessage>? messages;

  @HiveField(8)
  DateTime? lastUpdated;

  @HiveField(9)
  ChatMessage? lastMessage;

  @HiveField(10)
  int? unreadCount;

  Conversation({
    this.id,
    this.proprietaire,
    this.locataire,
    this.dateDebut,
    this.dateFin,
    this.active,
    this.bookingId,
    this.messages,
    this.lastUpdated,
    this.lastMessage,
    this.unreadCount,
  });

  static Conversation fromJsonAll(Map<String, dynamic> json) {
    return Conversation.fromJson(json);
  }

  Conversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    proprietaire = json['proprietaire'] != null
        ? User.fromJsonAll(json['proprietaire'])
        : null;

    locataire = json['locataire'] != null
        ? User.fromJsonAll(json['locataire'])
        : null;

    dateDebut = json['dateDebut'] != null
        ? DateTime.parse(json['dateDebut'])
        : null;

    dateFin = json['dateFin'] != null
        ? DateTime.parse(json['dateFin'])
        : null;

    active = json['active'];
    bookingId = json['bookingId'];

    if (json['messages'] != null) {
      messages = <ChatMessage>[];
      json['messages'].forEach((v) {
        messages!.add(ChatMessage.fromJson(v));
      });
    }

    lastUpdated = json['lastUpdated'] != null
        ? DateTime.parse(json['lastUpdated'])
        : DateTime.now();

    lastMessage = json['lastMessage'] != null
        ? ChatMessage.fromJson(json['lastMessage'])
        : null;

    unreadCount = json['unreadCount'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;

    if (proprietaire != null) {
      data['proprietaire'] = proprietaire!.toJson();
    }

    if (locataire != null) {
      data['locataire'] = locataire!.toJson();
    }

    data['dateDebut'] = dateDebut?.toIso8601String();
    data['dateFin'] = dateFin?.toIso8601String();
    data['active'] = active;
    data['bookingId'] = bookingId;

    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }

    data['lastUpdated'] = lastUpdated?.toIso8601String();

    if (lastMessage != null) {
      data['lastMessage'] = lastMessage!.toJson();
    }

    data['unreadCount'] = unreadCount;

    return data;
  }

  String get participantName {
    // Retourner le nom de l'autre participant selon le type d'utilisateur connecté
    if (proprietaire != null && locataire != null) {
      // Logic à adapter selon l'utilisateur connecté
      return proprietaire!.fullName.isNotEmpty
          ? proprietaire!.fullName
          : locataire!.fullName;
    }
    return 'Conversation';
  }

  String get lastMessagePreview {
    if (lastMessage?.contenu != null) {
      return lastMessage!.contenu!.length > 50
          ? '${lastMessage!.contenu!.substring(0, 50)}...'
          : lastMessage!.contenu!;
    }
    return 'Aucun message';
  }

  bool get hasUnreadMessages => (unreadCount ?? 0) > 0;

  @override
  String toString() {
    return toJson().toString();
  }
}