import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/service/auth/auth_manager.dart';
import 'package:asfar/service/model/Auth/authentication_service.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  late AuthenticationService authenticationService;

  UserBloc() : super(UserInitial()) {
    authenticationService = AuthenticationService();

    on<CheckStoredUser>((event, emit) async {
      try {
        // Charger l'utilisateur depuis StorageService
        final cachedUser = StorageService.instance.getUser();

        if (cachedUser != null) {
          // Charger le token depuis StorageService
          final token = StorageService.instance.getToken();

          // Synchroniser le token avec DioRequest (CRITIQUE!)
          if (token != null) {
            DioRequest.instance.setToken(token);
            deboger(["Token synchronisé avec DioRequest au démarrage"]);
          } else {
            deboger(["User trouvé mais pas de token - Déconnexion nécessaire"]);
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
      final currentUser = state.user;
      emit(UserLoading(user: currentUser));
      try {
        final user = await authenticationService.login(event.user);
        deboger(["user :", user]);

        // Sauvegarder l'utilisateur dans StorageService
        await StorageService.instance.saveUser(user);

        // Le token est déjà sauvegardé et synchronisé par AuthenticationService
        // via AuthManager.login() qui appelle StorageService.saveToken() et DioRequest.setToken()

        emit(UserLoaded(user));
      } catch (e) {
        ErrorHandler.logError("LOGIN", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(UserError(errorMessage, user: currentUser));
      }
    });

    on<SignupUser>((event, emit) async {
      final currentUser = state.user;
      emit(UserLoading(user: currentUser));
      try {
        final user = await authenticationService.signup(event.user);

        // Sauvegarder l'utilisateur dans StorageService
        await StorageService.instance.saveUser(user);

        emit(UserLoaded(user));
      } catch (e) {
        ErrorHandler.logError("SIGNUP", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(UserError(errorMessage, user: currentUser));
      }
    });

    on<SendOtp>((event, emit) async {
      final currentUser = state.user;
      emit(UserLoading(user: currentUser));
      try {
        await authenticationService.sendOtp(event.telephone);
        emit(OtpSent(event.telephone));
      } catch (e) {
        ErrorHandler.logError("SEND_OTP", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(UserError(errorMessage, user: currentUser));
      }
    });

    on<VerifyAndSignup>((event, emit) async {
      final currentUser = state.user;
      emit(UserLoading(user: currentUser));
      try {
        await authenticationService.verifyOtp(
          event.userReq.telephone ?? "",
          event.code,
        );
        final user = await authenticationService.signup(event.userReq);
        await StorageService.instance.saveUser(user);
        emit(UserLoaded(user));
      } catch (e) {
        ErrorHandler.logError("VERIFY_AND_SIGNUP", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(UserError(errorMessage, user: currentUser));
      }
    });

    on<LogoutUser>((event, emit) async {
      // Utiliser AuthManager pour un logout centralisé
      // Cela nettoie: token (StorageService + DioRequest) + AppData
      await AuthManager.instance.logout();

      emit(UserInitial());
    });
  }

  /// Récupère le téléphone de l'utilisateur connecté depuis StorageService
  static Future<String?> getCurrentUserPhone() async {
    try {
      final user = StorageService.instance.getUser();
      return user?.telephone;
    } catch (e) {
      deboger(["failed to get current user phone:", e]);
      return null;
    }
  }
}
