class PromptSubmissionResponse {
  bool result;
  int statusCode;
  bool response;

  PromptSubmissionResponse({
    required this.result,
    required this.statusCode,
    required this.response,
  });

  factory PromptSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return PromptSubmissionResponse(
      result: json['result'],
      statusCode: json['statusCode'],
      response: json['response'],
    );
  }
}