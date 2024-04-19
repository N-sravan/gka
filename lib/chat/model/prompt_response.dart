class ResponseModal {
  bool result;
  int statusCode;
  bool response;

  ResponseModal({
    required this.result,
    required this.statusCode,
    required this.response,
  });

  factory ResponseModal.fromJson(Map<String, dynamic> json) {
    return ResponseModal(
      result: json['result'],
      statusCode: json['statusCode'],
      response: json['response'],
    );
  }
}

class ResponseData {
  String promptTemplate;
  String intent;

  ResponseData({
    required this.promptTemplate,
    required this.intent,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      promptTemplate: json['prompt_template'],
      intent: json['intent'],
    );
  }
}
