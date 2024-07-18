class GetDocumentsResponseModel {
  int statusCode;
  Map<String, List<FileResponse>> response;

  GetDocumentsResponseModel({
    required this.statusCode,
    required this.response,
  });

  factory GetDocumentsResponseModel.fromJson(Map<String, dynamic> json) {
    var responseMap = json['response'] as Map<String, dynamic>;

    var convertedResponse = responseMap.map((key, value) {
      var pdfResponses =
          (value as List).map((e) => FileResponse.fromJson(e)).toList();
      return MapEntry(key, pdfResponses);
    });

    return GetDocumentsResponseModel(
      statusCode: json['statusCode'],
      response: convertedResponse,
    );
  }
}

class FileResponse {
  String? text;
  String? uuid;
  String? fileName;
  String? documentId;
  String? chunkUUID;
  String? fileUUID;

  FileResponse({
    this.text,
    this.uuid,
    this.fileName,
    this.documentId,
    this.chunkUUID,
    this.fileUUID,
  });

  factory FileResponse.fromJson(Map<String, dynamic> json) {
    return FileResponse(
        text: json['text'],
        uuid: json['uuid'],
        fileName: json['file_name'],
        documentId: json['document_id'].toString(),
        chunkUUID: json['chunk_uuid'],
        fileUUID: json['file_uuid']);
  }
}
