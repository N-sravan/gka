class ChatHistoryModel {
  final int statuscode;
  final List<ChatMessageHistoryModel> data;

  ChatHistoryModel({
    required this.statuscode,
    required this.data,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      statuscode: json['statuscode'],
      data: (json['response'] as List?)
              ?.map((item) => ChatMessageHistoryModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ChatMessageHistoryModel {
  final String createdAt;
  final int messageId;
  final String language;
  final String text;
  final String senderType;

  ChatMessageHistoryModel({
    required this.createdAt,
    required this.messageId,
    required this.language,
    required this.text,
    required this.senderType,
  });

  factory ChatMessageHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageHistoryModel(
      createdAt: json['created_at'],
      messageId: json['message_id'],
      language: json['language'],
      text: json['text'],
      senderType: json['sender_type'],
    );
  }
}



class ChatData {
  final bool isUser;
  final dynamic message;
  final String? sessionId;

  ChatData({
    required this.isUser,
    this.message,
    this.sessionId,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      isUser: json['is_user'],
      message: json['message'],
      sessionId: json['session_id'],
    );
  }
}

