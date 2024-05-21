import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../login/model/user_permission_response_model.dart';
import 'api_service_provider.dart';
import '../utils/app_state.dart';
import '../utils/common_constants.dart' as constants;
import '../login/model/department_user_permission_response.dart';

class ApiProvider {
  static ApiProvider? _instance;

  ApiProvider._();

  static ApiProvider get instance => _instance ??= ApiProvider._();

  @override
  Future<DepartmentUserPermissionsResponse> fetchUserPermissionsForSurveyorLogin(
      BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson,
      'Authorization': 'Bearer ${AppState.instance.token}',
      'Csrf-Token': AppState.instance.csrfToken
    };
    String authUrl =
        "${constants.baseUrl}${constants.userPermissionsEndPoint}${AppState.instance.userUUID}";
    http.Response response = await http.get(
      Uri.parse(authUrl),
      headers: authHeaders,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);
    DepartmentUserPermissionsResponse userPermissionsResult =
    DepartmentUserPermissionsResponse.fromJson(responseMap);
    return userPermissionsResult;
  }

  Future<dynamic?> uploadMedia(data,path,mediaType) async {
    String submissionUrl = constants.ngrok + constants.fileUploadEndPoint;
    Map<String, String> headersMap = {
      'Content-Type': constants.headerJson,
      "endpoints": constants.headerMultipart
    };

    var request = http.MultipartRequest('POST', Uri.parse(submissionUrl));
    File compressedFile;
    final bytes = File(path).readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final imageSize = kb / 1024;
    if(imageSize > 1) {
      compressedFile = await FlutterNativeImage.compressImage(
          path,
          quality: 50
      );
      var stream = http.ByteStream(compressedFile.openRead());
      var length = await compressedFile.length();
      var multipartFile = http.MultipartFile(
        'file', // Field name in the API endpoint
        stream,
        length,
        filename: path.split('/').last,
      );
      request.files.add(multipartFile);
    } else {
      File imageFile = File(path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'file', // Field name in the API endpoint
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
    }
    request.headers.addAll(headersMap);
    request.fields.addAll(data);
    var response = await request.send();
    var responseString = await response.stream.bytesToString();
    dynamic finalRes = json.decode(responseString);
    if(mediaType == 'file'){
      if(finalRes["statusCode"] == 200) {
        print("FILE SUBMISSION SUCCESS");
        return true;
      }
    }else{
      if(finalRes["message"] == "File uploaded successfully") {
        print("IMAGE SUBMISSION SUCCESS");
        return finalRes["url"];
      }
    }
    return null;
  }
}
