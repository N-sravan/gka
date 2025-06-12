import 'package:gka/utils/db_schema_constants.dart';

class OfflineChatHistoryResponse {
  final List<Session> response;
  final int statuscode;

  OfflineChatHistoryResponse(
      {required this.response, required this.statuscode});

  factory OfflineChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OfflineChatHistoryResponse(
      response:
          (json['response'] as List).map((e) => Session.fromJson(e)).toList(),
      statuscode: json['statuscode'],
    );
  }
}

class Session {
  late final String clientSessionId;
  final List<Message> messages;
  final String sessionCreatedAt;
  final int sessionDbId;
  final String? sessionName;
  final String sessionSelectedLanguage;

  Session({
    required this.clientSessionId,
    required this.messages,
    required this.sessionCreatedAt,
    required this.sessionDbId,
    this.sessionName,
    required this.sessionSelectedLanguage,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      clientSessionId: json['client_session_id'],
      messages:
          (json['messages'] as List).map((e) => Message.fromJson(e)).toList(),
      sessionCreatedAt: json['session_created_at'],
      sessionDbId: json['session_db_id'],
      sessionName: json['session_name'],
      sessionSelectedLanguage: json['session_selected_language'],
    );
  }
}

class Message {
  final String createdAt;
  final int messageId;
  final String originalLanguage;
  final String originalText;
  final String senderType;
  final List<Translation> translations;

  Message({
    required this.createdAt,
    required this.messageId,
    required this.originalLanguage,
    required this.originalText,
    required this.senderType,
    required this.translations,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      createdAt: json['created_at'],
      messageId: json['message_id'],
      originalLanguage: json['original_language'],
      originalText: json['original_text'],
      senderType: json['sender_type'],
      translations: (json['translations'] as List)
          .map((e) => Translation.fromJson(e))
          .toList(),
    );
  }
}

class Translation {
  final String language;
  final String translatedText;

  Translation({
    required this.language,
    required this.translatedText,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      language: json['language'],
      translatedText: json['translated_text'],
    );
  }
}

class OfflineChatModel {
  final String senderType;
  final String message;
  final String insertTs;

  OfflineChatModel({
    required this.senderType,
    required this.message,
    required this.insertTs,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[ChatHistoryEntry.senderType] = senderType;
    map[ChatHistoryEntry.message] = message;
    map[ChatHistoryEntry.insertTs] = insertTs;
    return map;
  }
}
