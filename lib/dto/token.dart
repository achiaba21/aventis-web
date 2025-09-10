import 'package:web_flutter/model/user/user.dart';

class Token {
  User? user;
  String? token;
  Token({this.user, this.token});

  Token.fromJson(Map<String, dynamic> json) {
    user = json["user"] == null ? null : User.fromJson(json["user"]);
    token = json["token"];
  }
}
