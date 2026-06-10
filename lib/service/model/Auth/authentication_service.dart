import 'package:dio/dio.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/dto/token.dart';
import 'package:asfar/dto/user_req.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/auth/auth_manager.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/response/http_function.dart';

class AuthenticationService {
  static String get urlLogin => "$domain/auth/login";
  static final urlSignupLocataire = "auth/signup";
  static String get urlSignupDemarcheur => "$domain/auth/signup/demarcheur";
  static final urlSignupProprietaire = "auth/signup/proprietaire";
  static String get urlOtpSend => "$domain/auth/otp/send";
  static String get urlOtpVerify => "$domain/auth/otp/verify";
  static String get urlLogout => "$domain/auth/logout";

  Future<User> login(User req) async {
    final dio = DioRequest.instance;
    final resp = await dio.post(urlLogin, data: req);

    if (hasError(resp)) {
      throw CustomException(resp.statusMessage ?? "");
    }
    final data = Token.fromJson(resp.data!);

    await AuthManager.instance.login(data.token!, data.user!);

    return data.user!;
  }

  Future<User> signup(UserReq req) async {
    final url = _signupUrlForRole(req.type);
    final dio = DioRequest.instance;
    final resp = await dio.post(url, data: req);
    if (hasError(resp)) {
      throw CustomException(resp.statusMessage ?? "");
    }
    final data = Token.fromJson(resp.data!);

    await AuthManager.instance.login(data.token!, data.user!);

    return data.user!;
  }

  String _signupUrlForRole(String? type) {
    switch (type) {
      case "Demarcheur":
        return urlSignupDemarcheur;
      case "Proprietaire":
        return urlSignupProprietaire;
      default:
        return urlSignupLocataire;
    }
  }

  Future<void> sendOtp(String telephone) async {
    final dio = DioRequest.instance;
    final resp = await dio.post(urlOtpSend, data: {
      "telephone": telephone,
      "type": "INSCRIPTION",
    });
    if (hasError(resp)) {
      throw CustomException(resp.statusMessage ?? "");
    }
  }

  Future<void> verifyOtp(String telephone, String code) async {
    final dio = DioRequest.instance;
    final resp = await dio.post(urlOtpVerify, data: {
      "telephone": telephone,
      "code": code,
      "type": "INSCRIPTION",
    });
    if (hasError(resp)) {
      throw CustomException(resp.statusMessage ?? "");
    }
  }

  Future<void> logout() async {
    await AuthManager.instance.logout();
  }

  /// Signale au serveur de révoquer le jeton de session courant (best-effort)
  ///
  /// L'endpoint `/auth/logout` est un prérequis backend : 404, timeout ou
  /// absence de réseau sont silencieusement ignorés — la déconnexion locale
  /// n'attend jamais cette révocation (RM7, fonctionne en mode avion).
  /// Le jeton est passé explicitement en header pour rester valable même si
  /// DioRequest est nettoyé pendant l'envoi.
  static Future<void> revokeToken() async {
    final token = StorageService.instance.getToken();
    if (token == null || token.isEmpty) return;
    try {
      await DioRequest.instance
          .post(
            urlLogout,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      // Best-effort : ne doit jamais bloquer ni faire échouer le logout local.
    }
  }
}
