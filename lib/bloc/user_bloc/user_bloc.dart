import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/user_bloc/user_event.dart';
import 'package:web_flutter/bloc/user_bloc/user_state.dart';
import 'package:web_flutter/service/model/Auth/authentication_service.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/function.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  late AuthenticationService authenticationService;

  UserBloc() : super(UserInitial()) {
    authenticationService = AuthenticationService();

    on<LoginUser>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await authenticationService.login(event.user);

        emit(UserLoaded(user));
      } on CustomException catch (e) {
        emit(UserError(e.message));
      } catch (e) {
        emit(UserError("Une erreur est survenu"));

        deboger(e);
      }
    });

    on<LogoutUser>((event, emit) async {
      await authenticationService.logout(event.user);
    });
  }
}
