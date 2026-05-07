import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/dto/token.dart';
import 'package:asfar/dto/user_req.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/auth/auth_manager.dart';
import 'package:asfar/service/dio/dio_request.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/response/http_function.dart';

class AuthenticationService {
  static String get urlLogin => "http://$serveur:$port/auth/login";
  static final urlSignupLocataire = "auth/signup";
  static String get urlSignupDemarcheur => "http://$serveur:$port/auth/signup/demarcheur";
  static final urlSignupProprietaire = "auth/signup/proprietaire";
  static String get urlOtpSend => "http://$serveur:$port/auth/otp/send";
  static String get urlOtpVerify => "http://$serveur:$port/auth/otp/verify";

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
}
