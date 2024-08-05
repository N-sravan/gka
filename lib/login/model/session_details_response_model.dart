class SessionDetails {
  String? sessionId;
  String? token;
  String userId;
  String? userType;

  SessionDetails({this.sessionId, this.token, required this.userId, this.userType});

  factory SessionDetails.fromJson(Map<String, dynamic> json) {
    return SessionDetails(
        sessionId: json['session_id'],
        token: json['token'],
        userId: json['user_id'],
        userType: json['user_type'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'token': token,
      'user_id': userId,
      'user_type': userType,
    };
  }
}
