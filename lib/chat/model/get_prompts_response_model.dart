class GetAllPromptsResponseModel {
  bool? result;
  int? statusCode;
  List<Response>? response;

  GetAllPromptsResponseModel({this.result, this.statusCode, this.response});

  GetAllPromptsResponseModel.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    statusCode = json['statusCode'];
    if (json['response'] != null) {
      response = [];
      json['response'].forEach((v) {
        response?.add(Response.fromJson(v));
      });
    }
  }
}

class Response {
  String? modelName;
  String? promptTemplate;
  String? intent;

  Response({this.modelName, this.promptTemplate, this.intent});

  Response.fromJson(Map<String, dynamic> json) {
    modelName = json['model_name'];
    promptTemplate = json['prompt_template'];
    intent = json['intent'];
  }
}