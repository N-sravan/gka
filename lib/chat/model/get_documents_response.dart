class GetDocumentsResponseModel {
  int? statusCode;
  List<Response>? response;

  GetDocumentsResponseModel({this.statusCode, this.response});

  GetDocumentsResponseModel.fromJson(Map<String, dynamic> json) {
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
  String? content;
  String? id;

  Response({this.content, this.id});

  Response.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    id = json['id'];
  }
}
