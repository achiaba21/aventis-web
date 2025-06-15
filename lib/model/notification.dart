import 'package:web_flutter/model/user/user.dart';

class Notification2  {
  String? contenu;
  User? users;
  DateTime? createdAt;
  String? title;

  Notification2({this.contenu, this.users});

  Notification2.fromJson(Map<String, dynamic> json)  {
    contenu = json['contenu'];
    users = json['users'] != null ? User.fromJson(json['users']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['contenu'] = this.contenu;
    if (this.users != null) {
      data['users'] = this.users!.toJson();
    }
    return data;
  }
}