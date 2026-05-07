import 'package:asfar/model/user/user.dart';

/// État de base pour l'utilisateur
///
/// Pattern "keep last known data" : conserve l'utilisateur connu
/// même pendant les transitions d'état pour éviter les flashs UI
abstract class UserState {
  /// Dernier utilisateur connu (persisté entre les états)
  final User? user;

  UserState({this.user});
}

class UserInitial extends UserState {
  UserInitial({super.user});
}

class UserLoading extends UserState {
  UserLoading({super.user});
}

class UserLoaded extends UserState {
  UserLoaded(User user) : super(user: user);

  /// Accès garanti non-null à l'utilisateur (pour UserLoaded seulement)
  User get loadedUser => user!;
}

class UserError extends UserState {
  final String message;
  UserError(this.message, {super.user});
}

class OtpSent extends UserState {
  final String telephone;
  OtpSent(this.telephone) : super(user: null);
}
