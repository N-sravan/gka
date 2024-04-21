class AvailabeModelResponse {
  bool? result;
  int? statusCode;
  List<Response>? response;

  AvailabeModelResponse({this.result, this.statusCode, this.response});

  AvailabeModelResponse.fromJson(Map<String, dynamic> json) {
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
  String? modelUuid;
  String? modelName;

  Response({this.modelUuid, this.modelName});

  Response.fromJson(Map<String, dynamic> json) {
    modelUuid = json['model_uuid'];
    modelName = json['model_name'];
  }
}