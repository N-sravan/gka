class ActivityStatusResponse {
  final int? statusCode;
  final Response? response;

  ActivityStatusResponse({
    this.statusCode,
    this.response,
  });

  // Factory method to create an instance from a JSON object
  factory ActivityStatusResponse.fromJson(Map<String, dynamic> json) {
    return ActivityStatusResponse(
      statusCode: json['statusCode'],
      response: Response.fromJson(json['response']),
    );
  }
}

class Response {
  final int? maxTokens;
  final int? availableTokens;
  final int? usedTokens;

  Response({
    this.maxTokens,
    this.availableTokens,
    this.usedTokens,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      maxTokens: json['max_tokens'],
      availableTokens: json['available_tokens'],
      usedTokens: json['used_tokens'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_tokens': maxTokens,
      'available_tokens': availableTokens,
      'used_tokens': usedTokens,
    };
  }
}
