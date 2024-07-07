class SessionDetails {
  String? sessionId;
  String? token;
  String userId;

  SessionDetails({
     this.sessionId,
     this.token,
    required this.userId,
  });

  factory SessionDetails.fromJson(Map<String, dynamic> json) {
    return SessionDetails(
        sessionId: json['session_id'],
        token: json['token'],
        userId: json['user_id']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'token': token,
      // 'user_id': userId,
    };
  }
}
