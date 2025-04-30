class ChatMessageHistory {
  final String id;
  final String flowId;
  final String timestamp;
  final String sender;
  final String senderName;
  final String sessionId;
  final String text;
  final String files;
  final bool edit;
  final MessageProperties properties;
  final String category;
  final List<dynamic> contentBlocks;

  ChatMessageHistory({
    required this.id,
    required this.flowId,
    required this.timestamp,
    required this.sender,
    required this.senderName,
    required this.sessionId,
    required this.text,
    required this.files,
    required this.edit,
    required this.properties,
    required this.category,
    required this.contentBlocks,
  });

  factory ChatMessageHistory.fromJson(Map<String, dynamic> json) {
    return ChatMessageHistory(
      id: json['id'],
      flowId: json['flow_id'],
      timestamp: json['timestamp'],
      sender: json['sender'],
      senderName: json['sender_name'],
      sessionId: json['session_id'],
      text: json['text'],
      files: json['files'],
      edit: json['edit'],
      properties: MessageProperties.fromJson(json['properties']),
      category: json['category'],
      contentBlocks: json['content_blocks'] ?? [],
    );
  }
}

class MessageProperties {
  final String textColor;
  final String backgroundColor;
  final bool edited;
  final Source source;
  final String icon;
  final bool allowMarkdown;
  final dynamic positiveFeedback;
  final String state;
  final List<dynamic> targets;

  MessageProperties({
    required this.textColor,
    required this.backgroundColor,
    required this.edited,
    required this.source,
    required this.icon,
    required this.allowMarkdown,
    required this.positiveFeedback,
    required this.state,
    required this.targets,
  });

  factory MessageProperties.fromJson(Map<String, dynamic> json) {
    return MessageProperties(
      textColor: json['text_color'] ?? '',
      backgroundColor: json['background_color'] ?? '',
      edited: json['edited'],
      source: Source.fromJson(json['source']),
      icon: json['icon'] ?? '',
      allowMarkdown: json['allow_markdown'],
      positiveFeedback: json['positive_feedback'],
      state: json['state'],
      targets: json['targets'] ?? [],
    );
  }
}

class Source {
  final String? id;
  final String? displayName;
  final String? source;

  Source({this.id, this.displayName, this.source});

  factory Source.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Source(id: null, displayName: null, source: null);
    }
    return Source(
      id: json['id'],
      displayName: json['display_name'],
      source: json['source'],
    );
  }
}