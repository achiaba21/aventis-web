import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:web_flutter/bloc/user_bloc/user_event.dart';
import 'package:web_flutter/bloc/user_bloc/user_state.dart';
import 'package:web_flutter/model/user/user.dart';
import 'package:web_flutter/service/model/Auth/authentication_service.dart';
import 'package:web_flutter/service/local_store.dart';
import 'package:web_flutter/service/dio/dio_request.dart';
import 'package:web_flutter/util/error_handler.dart';
import 'package:web_flutter/util/function.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  late AuthenticationService authenticationService;
  static const String _userKey = 'stored_user';

  UserBloc() : super(UserInitial()) {
    authenticationService = AuthenticationService();

    on<CheckStoredUser>((event, emit) async {
      try {
        final cachedUser = await _loadStoredUser();
        if (cachedUser != null) {
          final token = await LocalStore.token;
          if (token != null) {
            DioRequest.instance.setToken(token);
          }
          deboger(["stored user found:", cachedUser.fullName]);
          emit(UserLoaded(cachedUser));
        } else {
          deboger(["no stored user found"]);
        }
      } catch (e) {
        deboger(["error loading stored user:", e]);
      }
    });

    on<LoginUser>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await authenticationService.login(event.user);
        deboger(["user :", user]);

        await _saveUser(user);
        emit(UserLoaded(user));
      } catch (e) {
        ErrorHandler.logError("LOGIN", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(UserError(errorMessage));
      }
    });

    on<SignupUser>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await authenticationService.signup(event.user);

        await _saveUser(user);
        emit(UserLoaded(user));
      } catch (e) {
        ErrorHandler.logError("SIGNUP", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(UserError(errorMessage));
      }
    });

    on<LogoutUser>((event, emit) async {
      await authenticationService.logout(event.user);
      await _removeStoredUser();
      await _removeStoredToken();
      emit(UserInitial());
    });
  }

  Future<void> _saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      deboger(["user saved to storage"]);
    } catch (e) {
      deboger(["failed to save user:", e]);
    }
  }

  Future<User?> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJsonAll(userMap);
      }
      return null;
    } catch (e) {
      deboger(["failed to load stored user:", e]);
      return null;
    }
  }

  Future<void> _removeStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      deboger(["user removed from storage"]);
    } catch (e) {
      deboger(["failed to remove stored user:", e]);
    }
  }

  Future<void> _removeStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      deboger(["token removed from storage"]);
    } catch (e) {
      deboger(["failed to remove stored token:", e]);
    }
  }

  /// Récupère le téléphone de l'utilisateur connecté depuis le cache
  static Future<String?> getCurrentUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final user = User.fromJsonAll(userMap);
        return user.telephone;
      }
      return null;
    } catch (e) {
      deboger(["failed to get current user phone:", e]);
      return null;
    }
  }
}
