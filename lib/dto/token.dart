import 'package:asfar/model/user/user.dart';

class Token {
  User? user;
  String? token;

  /// Refresh token opaque (rotation à chaque usage côté backend, TTL 30j).
  String? refreshToken;

  Token({this.user, this.token, this.refreshToken});

  Token.fromJson(Map<String, dynamic> json) {
    user = json["user"] == null ? null : User.fromJsonAll(json["user"]);
    token = json["token"];
    refreshToken = json["refreshToken"];
  }
}
