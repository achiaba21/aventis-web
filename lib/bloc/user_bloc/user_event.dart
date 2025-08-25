import 'package:web_flutter/model/user/user.dart';

abstract class UserEvent {}

class LoginUser extends UserEvent {
  User user;
  LoginUser(this.user);
}

class LogoutUser extends UserEvent {
  User user;
  LogoutUser(this.user);
}
