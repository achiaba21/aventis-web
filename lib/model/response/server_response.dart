class ServerResponse<T> {
  final T body;
  final String message;

  ServerResponse({
    required this.body,
    required this.message,
  });

  factory ServerResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) bodyFromJson,
  ) {
    return ServerResponse<T>(
      body: bodyFromJson(json['body']),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson(Object Function(T) bodyToJson) {
    return {
      'body': bodyToJson(body),
      'message': message,
    };
  }
}