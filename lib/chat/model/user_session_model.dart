class UserSessionModel {
  final List<UserSession> data;
  final Pagination pagination;

  UserSessionModel({required this.data, required this.pagination});

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    return UserSessionModel(
      data: (json['response'] as List)
          .map((e) => UserSession.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class UserSession {
  final String userId;
  final String sessionId;
  final String insertTs;

  UserSession({
    required this.userId,
    required this.sessionId,
    required this.insertTs,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['user_id'],
      sessionId: json['session_id'],
      insertTs: json['insert_ts'],
    );
  }
}

class Pagination {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'],
      pageSize: json['page_size'],
      totalCount: json['total_count'],
      totalPages: json['total_pages'],
      hasNext: json['has_next'],
      hasPrevious: json['has_previous'],
    );
  }
}
