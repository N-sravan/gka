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
  String? category;
  String? uploadedDate;
  UserDetails? userDetails;

  FileResponse({
    this.text,
    this.uuid,
    this.fileName,
    this.documentId,
    this.chunkUUID,
    this.fileUUID,
    this.category,
    this.uploadedDate,
    this.userDetails,
  });

  factory FileResponse.fromJson(Map<String, dynamic> json) {
    return FileResponse(
      text: json['text'],
      uuid: json['uuid'],
      fileName: json['file_name'],
      documentId: json['document_id']?.toString(),
      chunkUUID: json['chunk_uuid'],
      fileUUID: json['file_uuid'],
      category: json['category'],
      uploadedDate: json['uploaded_date'],
      userDetails: json['user_details'] != null
          ? UserDetails.fromJson(json['user_details'])
          : null,
    );
  }
}

class UserDetails {
  String? name;
  String? phone;
  String? userUUID;

  UserDetails({
    this.name,
    this.phone,
    this.userUUID,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      name: json['name'],
      phone: json['phone'],
      userUUID: json['user_uuid'],
    );
  }
}
