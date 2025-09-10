import 'package:web_flutter/dto/token.dart';
import 'package:web_flutter/dto/user_req.dart';
import 'package:web_flutter/model/user/user.dart';
import 'package:web_flutter/service/dio/dio_request.dart';
import 'package:web_flutter/service/local_store.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/response/http_function.dart';

class AuthenticationService {
  static final urlLogin = "auth/login";
  static final urlSignup = "auth/signup";
  Future<User> login(User req) async {
    final dio = DioRequest.instance;
    final resp = await dio.post(urlLogin, data: req);

    if (hasError(resp)) {
      throw CustomException(resp.statusMessage ?? "");
    }
    final data = Token.fromJson(resp.data!);
    LocalStore.setToken(data.token!);
    return data.user!;
  }

  Future<User> signup(UserReq req) async {
    final dio = DioRequest.instance;
    final resp = await dio.post(urlSignup, data: req);
    if (hasError(resp)) {
      throw CustomException(resp.statusMessage ?? "");
    }
    final data = Token.fromJson(resp.data!);
    LocalStore.setToken(data.token!);
    return data.user!;
  }

  Future<void> logout(User req) async {}
}
