import 'package:dio/dio.dart';

bool hasError(Response res) {
  int statuCode = res.statusCode ?? 0;
  if (statuCode > 199 && statuCode < 300) {
    return false;
  }
  return true;
}
