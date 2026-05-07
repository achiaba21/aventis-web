import 'package:asfar/model/user/user.dart';

class UserReq extends User {
  String? confirmPassword;

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data["confirmePass"] = confirmPassword;
    return data;
  }
}
