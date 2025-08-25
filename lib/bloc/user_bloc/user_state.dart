import 'package:web_flutter/model/user/client.dart';
import 'package:web_flutter/model/user/user.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  User user;
  UserLoaded(this.user);
}

class UserError extends UserState {
  String message;
  UserError(this.message);
}
