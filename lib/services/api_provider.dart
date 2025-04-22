import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/shared/loading_view_model.dart';
import 'package:http/http.dart' as http;
import '../chat/model/chat_history_model.dart';
import '../chat/model/chat_message_history.dart';
import '../chat/repo/chat_repo.dart';
import '../login/model/user_permission_response_model.dart';
import '../utils/app_state.dart';
import '../utils/common_constants.dart' as constants;
import '../login/model/department_user_permission_response.dart';
import '../utils/network_utils.dart';
import '../utils/util.dart';

class ApiProvider extends LoadingViewModel {
  static ApiProvider? _instance;

  ApiProvider._();

  static ApiProvider get instance => _instance ??= ApiProvider._();



  Future<dynamic> uploadMedia(data, path, mediaType) async {
    String submissionUrl = '';
    if (mediaType == 'file') {
      submissionUrl = constants.baseUrl + constants.uploadDocumentEndpoint;
    } else {
      submissionUrl = constants.imageUploadUrl;
    }
    Map<String, String> headersMap = {
      'Content-Type': constants.headerJson,
      "endpoints": constants.headerMultipart
    };

    print("SUBMISSION URL::$submissionUrl");
    var request = http.MultipartRequest('POST', Uri.parse(submissionUrl));
    File compressedFile;
    final bytes = File(path).readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final imageSize = kb / 1024;
    if (imageSize > 1) {
      compressedFile =
          await FlutterNativeImage.compressImage(path, quality: 50);
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
    if (mediaType == 'file') {
      if (finalRes["statusCode"] == 200) {
        print("FILE SUBMISSION SUCCESS");
        return true;
      }
    } else {
      if (finalRes["message"] == "File uploaded successfully") {
        print("IMAGE SUBMISSION SUCCESS");
        return finalRes["url"];
      }
    }
    return null;
  }

    Future<UserPermissionsResponse?> fetchUserPermissions(
        BuildContext context) async {
      // ApiServiceProvider apiServiceProvider = ApiServiceProvider();
      Map<String, String> authHeaders = {
        constants.headerContentType: constants.headerJson,
        'Authorization': 'Bearer ${AppState.instance.token}',
      };
      // authHeaders.addAll(apiServiceProvider.headers);
      String authUrl = constants.userPermissionsEndPoint;
      http.Response response = await http.get(
        Uri.parse(authUrl),
        headers: authHeaders,
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = jsonDecode(response.body);
        if (responseMap["result"]) {
          AppState.instance.userPermissions = responseMap["response"]["rolePermissions"] ?? {};
          AppState.instance.userMetaDataMap =
              responseMap["response"]["meta"] ?? {};
          UserPermissionsResponse userPermissionsResult =
              UserPermissionsResponse.fromJson(responseMap);
          return userPermissionsResult;
        }
        return null;
      }
      return null;
    }

  Future<List<ChatMessageHistory>> fetchMessageHistory(
      String sessionId, BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson,
      'x-api-key': 'sk-wB4MAe1kOlMMRmdX0KfpwhwMNP8HaKjLnNdsiIdCtxc',
    };

    String encodedSessionId = Uri.encodeComponent(sessionId);
    String flowId = 'd38adaab-877c-4a47-a35c-047affbf1102';

    String authUrl =
        "https://agentsbuilder.apaims2.0.vassarlabs.com/api/v1/monitor/messages?session_id=$encodedSessionId&flow_id=$flowId";

    // String authUrl = Uri.encodeFull('https://agentsbuilder.apaims2.0.vassarlabs.com/api/v1/monitor/messages?session_id=$sessionId&flow_id=$flowId');

    var response = await http.get(Uri.parse(authUrl), headers: authHeaders);

    if (response.statusCode == 200) {
      List<dynamic> responseList = jsonDecode(response.body);

      return responseList
          .map((json) => ChatMessageHistory.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load message history: ${response.statusCode}');
    }
  }
}
