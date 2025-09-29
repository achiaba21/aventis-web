import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/model/response/server_response.dart';

class FavoriteAppartementsResponse extends ServerResponse<List<Appartement>> {
  FavoriteAppartementsResponse({
    required super.body,
    required super.message,
  });

  factory FavoriteAppartementsResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteAppartementsResponse(
      body: (json['body'] as List)
          .map((item) => Appartement.fromJson(item))
          .toList(),
      message: json['message'] ?? '',
    );
  }
}