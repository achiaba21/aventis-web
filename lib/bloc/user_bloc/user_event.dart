import 'package:asfar/dto/user_req.dart';
import 'package:asfar/model/user/user.dart';

abstract class UserEvent {}

class LoginUser extends UserEvent {
  User user;
  LoginUser(this.user);
}

class SignupUser extends UserEvent {
  UserReq user;
  SignupUser(this.user);
}

class LogoutUser extends UserEvent {
  User user;
  LogoutUser(this.user);
}

class CheckStoredUser extends UserEvent {}

class SendOtp extends UserEvent {
  final String telephone;
  SendOtp(this.telephone);
}

class VerifyAndSignup extends UserEvent {
  final String code;
  final UserReq userReq;
  VerifyAndSignup(this.code, this.userReq);
}
