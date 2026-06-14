import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/service/auth/auth_manager.dart';
import 'package:asfar/service/auth/token_refresh_coordinator.dart';
import 'package:asfar/service/auth/token_validator.dart';
import 'package:asfar/service/model/Auth/authentication_service.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  late AuthenticationService authenticationService;

  UserBloc({AuthenticationService? authentication}) : super(UserInitial()) {
    authenticationService = authentication ?? AuthenticationService();

    on<CheckStoredUser>((event, emit) async {
      try {
        // Charger l'utilisateur depuis StorageService
        final cachedUser = StorageService.instance.getUser();

        if (cachedUser != null) {
          // Charger le token depuis StorageService
          final token = StorageService.instance.getToken();

          // Valider le jeton AVANT de restaurer la session (RM6) :
          // un jeton absent, expiré ou illisible ramène au login
          // sans aucun appel métier préalable.
          if (TokenValidator.isValid(token)) {
            // Synchroniser le token avec DioRequest (CRITIQUE!)
            DioRequest.instance.setToken(token!);
            deboger(["Token valide synchronisé avec DioRequest au démarrage"]);
            deboger(["stored user found"]);
            emit(UserLoaded(cachedUser));
          } else {
            // Access expiré : tenter un refresh (TTL refresh 30j) avant de
            // déconnecter — évite de renvoyer l'utilisateur au login à chaque
            // redémarrage après l'heure de vie de l'access token.
            deboger(["Access expiré au démarrage - tentative de refresh"]);
            final refreshed = await TokenRefreshCoordinator.instance.refresh();
            if (refreshed) {
              deboger(["Refresh OK au démarrage - session restaurée"]);
              emit(UserLoaded(StorageService.instance.getUser() ?? cachedUser));
            } else {
              deboger(["Refresh impossible au démarrage - déconnexion"]);
              await AuthManager.instance.logout();
            }
          }
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

    on<VerifyOtp>((event, emit) async {
      final currentUser = state.user;
      emit(UserLoading(user: currentUser));
      try {
        await authenticationService.verifyOtp(event.telephone, event.code);
        emit(OtpVerified(event.telephone));
      } catch (e) {
        ErrorHandler.logError("VERIFY_OTP", e);
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
