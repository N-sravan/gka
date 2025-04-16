class ChatHistoryModel {
  final int status;
  final List<ChatHistoryItem> data;

  ChatHistoryModel({
    required this.status,
    required this.data,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      status: json['statuscode'],
      data: (json['response'] as List?)
          ?.map((item) => ChatHistoryItem.fromJson(item))
          .toList() ??
          [],
    );
  }
}


class ChatHistoryItem {
  final String sessionId;
  final String user;
  final String message;

  ChatHistoryItem({
    required this.sessionId,
    required this.user,
    required this.message,
  });

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      sessionId: json['session_id'],
      user: json['user_id'],
      message: json['data'],
    );
  }
}

class ChatData {
  final bool isUser;
  final String message;

  ChatData({
    required this.isUser,
    required this.message,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      isUser: json['is_user'],
      message: json['message'],
    );
  }
}
