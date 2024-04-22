class TokenResponse {
  int? statusCode;
  String? message;

  TokenResponse({
    this.statusCode,
    this.message,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      statusCode: json['statusCode'],
      message: json['message'],
    );
  }
}