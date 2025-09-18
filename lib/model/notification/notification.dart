import 'package:web_flutter/model/user/user.dart';

enum NotificationEvent {
  reservation('RERSERVATION'),
  message('MESSAGE'),
  notification('NOTIFICATION');

  const NotificationEvent(this.value);
  final String value;

  static NotificationEvent fromString(String value) {
    return NotificationEvent.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationEvent.notification,
    );
  }
}

enum NotificationStatus {
  enAttente('EN_ATTENTE'),
  lue('LUE'),
  archivee('ARCHIVEE');

  const NotificationStatus(this.value);
  final String value;

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationStatus.enAttente,
    );
  }
}

class NotificationModel {
  int? id;
  String? titre;
  String? contenu;
  User? user;
  NotificationEvent event;
  NotificationStatus status;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Données additionnelles pour l'action
  Map<String, dynamic>? actionData;

  NotificationModel({
    this.id,
    this.titre,
    this.contenu,
    this.user,
    this.event = NotificationEvent.notification,
    this.status = NotificationStatus.enAttente,
    this.createdAt,
    this.updatedAt,
    this.actionData,
  });

  NotificationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        titre = json['titre'],
        contenu = json['contenu'],
        user = json['user'] != null ? User.fromJson(json['user']) : null,
        event = NotificationEvent.fromString(json['event'] ?? 'NOTIFICATION'),
        status = NotificationStatus.fromString(json['status'] ?? 'EN_ATTENTE'),
        createdAt = json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
        updatedAt = json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : null,
        actionData = json['actionData'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['id'] = id;
    if (titre != null) data['titre'] = titre;
    if (contenu != null) data['contenu'] = contenu;
    if (user != null) data['user'] = user!.toJson();
    data['event'] = event.value;
    data['status'] = status.value;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    if (actionData != null) data['actionData'] = actionData;
    return data;
  }

  // Getters utilitaires
  bool get isUnread => status == NotificationStatus.enAttente;
  bool get isReservation => event == NotificationEvent.reservation;
  bool get isMessage => event == NotificationEvent.message;

  String get timeAgo {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'Maintenant';
    }
  }

  String get displayTitle => titre ?? _getDefaultTitle();

  String _getDefaultTitle() {
    switch (event) {
      case NotificationEvent.reservation:
        return 'Réservation';
      case NotificationEvent.message:
        return 'Nouveau message';
      case NotificationEvent.notification:
        return 'Notification';
    }
  }

  NotificationModel markAsRead() {
    return NotificationModel(
      id: id,
      titre: titre,
      contenu: contenu,
      user: user,
      event: event,
      status: NotificationStatus.lue,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      actionData: actionData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel{id: $id, titre: $titre, event: $event, status: $status}';
  }
}