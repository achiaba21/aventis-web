import 'package:web_flutter/model/user/user.dart';

class UserReq extends User {
  String? confirmPassword;

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data["cofirmePass"] = confirmPassword;
    return data;
  }
}
