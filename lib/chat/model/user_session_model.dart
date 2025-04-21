class UserSessionModel {
  final int status;
  final List<SessionHistoryModel> data;

  UserSessionModel({
    required this.status,
    required this.data,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      status: json['statuscode'],
      data: (json['response'] as List?)
              ?.map((item) => SessionHistoryModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class SessionHistoryModel {
  final String sessionId;
  final String userId;
  final String insertTs;

  SessionHistoryModel({
    required this.sessionId,
    required this.userId,
    required this.insertTs,
  });

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SessionHistoryModel(
      sessionId: json['session_id'],
      userId: json['user_id'],
      insertTs: json['insert_ts'],
    );
  }
}
