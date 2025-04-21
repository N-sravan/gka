import 'package:gka/chat/model/user_session_model.dart';

class ChatHistoryModel {
  final int status;
  final List<SessionHistoryModel> data;

  ChatHistoryModel({
    required this.status,
    required this.data,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      status: json['statuscode'],
      data: (json['response'] as List?)
              ?.map((item) => SessionHistoryModel.fromJson(item))
              .toList() ??
          [],
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

