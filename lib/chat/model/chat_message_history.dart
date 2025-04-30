class ChatMessageHistory {
  final String id;
  final String role;
  final String chatflowId;
  final String content;
  final String chatType;
  final String chatId;
  final String memoryType;
  final String sessionId;
  final DateTime createdDate;
  final List<dynamic>? sourceDocuments;
  final List<dynamic>? usedTools;
  final List<dynamic>? fileAnnotations;
  final dynamic agentReasoning;
  final List<dynamic>? fileUploads;
  final List<dynamic>? artifacts;
  final dynamic action;
  final String? leadEmail;
  final List<dynamic>? followUpPrompts;

  ChatMessageHistory({
    required this.id,
    required this.role,
    required this.chatflowId,
    required this.content,
    required this.chatType,
    required this.chatId,
    required this.memoryType,
    required this.sessionId,
    required this.createdDate,
    this.sourceDocuments,
    this.usedTools,
    this.fileAnnotations,
    this.agentReasoning,
    this.fileUploads,
    this.artifacts,
    this.action,
    this.leadEmail,
    this.followUpPrompts,
  });

  factory ChatMessageHistory.fromJson(Map<String, dynamic> json) {
    return ChatMessageHistory(
      id: json['id'],
      role: json['role'],
      chatflowId: json['chatflowid'],
      content: json['content'],
      chatType: json['chatType'],
      chatId: json['chatId'],
      memoryType: json['memoryType'],
      sessionId: json['sessionId'],
      createdDate: DateTime.parse(json['createdDate']),
      sourceDocuments: json['sourceDocuments'],
      usedTools: json['usedTools'],
      fileAnnotations: json['fileAnnotations'],
      agentReasoning: json['agentReasoning'],
      fileUploads: json['fileUploads'],
      artifacts: json['artifacts'],
      action: json['action'],
      leadEmail: json['leadEmail'],
      followUpPrompts: json['followUpPrompts'],
    );
  }
}
