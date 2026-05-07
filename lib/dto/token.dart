import 'package:asfar/model/user/user.dart';

class Token {
  User? user;
  String? token;
  Token({this.user, this.token});

  Token.fromJson(Map<String, dynamic> json) {
    user = json["user"] == null ? null : User.fromJsonAll(json["user"]);
    token = json["token"];
  }
}
