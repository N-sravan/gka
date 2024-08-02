class SessionDetails {
  String? sessionId;
  String? token;
  String userId;
  String? role;

  SessionDetails({this.sessionId, this.token, required this.userId, this.role});

  factory SessionDetails.fromJson(Map<String, dynamic> json) {
    return SessionDetails(
        sessionId: json['session_id'],
        token: json['token'],
        userId: json['user_id'],
        role: json['user_type'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'token': token,
      // 'role': role,
      // 'user_id': userId,
    };
  }
}
