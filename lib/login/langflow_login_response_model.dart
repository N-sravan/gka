
class LangflowLoginModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  LangflowLoginModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory LangflowLoginModel.fromJson(Map<String, dynamic> json) {
    return LangflowLoginModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}
