import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gka/login/langflow_login_response_model.dart';
import 'package:gka/login/model/session_details_response_model.dart';
import 'package:gka/login/model/ap_login_response_model.dart';
import 'package:gka/login/model/kerala_login_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../shared/token_response.dart';
import '../../utils/app_state.dart';
import '../model/login_api_response_model.dart';
import 'package:gka/utils/common_constants.dart' as constants;

/// Abstract class for the login repository
abstract class LoginRepository {
  Future<SessionDetails?> authentication(
      Map<String, String> params, BuildContext context);

  Future<LoginResult> authenticate(
      Map<String, String> params, BuildContext context);

  Future<LangflowLoginModel> langflowAuthenticate(
      Map<String, String> params, BuildContext context);

  Future fetchCsrfToken(BuildContext context);

  Future<int?> sendSessionId(BuildContext context, String sessionId);

  Future<int?> saveFcmToken(BuildContext context);
}

class LoginRepositoryImpl extends LoginRepository {
  @override
  Future<LoginResult> authenticate(
      Map<String, String> params, BuildContext context) async {
    String credentials = '${params['username']}:${params['password']}';

    String encoded = base64Encode(utf8.encode(credentials));
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson,
      'Authorization': 'Basic $encoded'
    };
    String authUrl = constants.loginEndpointForAcessToken;
    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    LoginResult loginResult = LoginResult.fromJson(responseMap['response']);
    loginResult.statusCode = response.statusCode;
    return loginResult;
  }

  Future<LangflowLoginModel> langflowAuthenticate(
      Map<String, String> params, BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerContentTypeFormUrl,
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMjU1YWRjNy0xMjA2LTQwMmUtOWIyYS0zZTQ3MTljZDdmMmQiLCJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQ2NTE5MjY2fQ.7s-k0BmSxE0xDjhI8JpGvU12W6pGOhuVIA-Rtlfzys8',
    };

    String authUrl = constants.langflowLoginEndpoint;

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: params,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    LangflowLoginModel langflowLoginModel =
        LangflowLoginModel.fromJson(responseMap);
    return langflowLoginModel;
  }

  @override
  Future<int?> saveFcmToken(BuildContext context) async {
    Map<String, dynamic> params = {
      "fcmToken": AppState.instance.fcmToken,
      "userId": AppState.instance.userId,
      "locationUuid": AppState.instance.locUUID,
      "locationType": AppState.instance.locType,
      "locationName": AppState.instance.locName,
      "project_uuid": constants.gowaterUUID
    };
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.genAiBaseUrl + constants.saveFcmTokenEndpoint;
    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    // LoginResult loginResult = LoginResult.fromJson(responseMap);
    TokenResponse tokenResponse = TokenResponse.fromJson(responseMap);
    return tokenResponse.statusCode;
  }

  @override
  Future fetchCsrfToken(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson,
      'Authorization': 'Bearer ${AppState.instance.token}'
    };
    String authUrl = constants.csrfEndPoint;
    http.Response response = await http.get(
      Uri.parse(authUrl),
      headers: authHeaders,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    return responseMap;
  }

  @override
  Future<SessionDetails?> authentication(
      Map<String, String> params, BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Object data = jsonEncode(params);
    String authUrl = '${constants.baseUrl}auth_and_session/login';
    print("wewewew app name:${constants.appTitle} auth_url ::$authUrl");
    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: data,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    SessionDetails sessionDetails =
        SessionDetails.fromJson(responseMap['session_details']);
    return sessionDetails;
  }

  @override
  Future<int?> sendSessionId(BuildContext context, String sessionId) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, dynamic> params = {
      "user_id": AppState.instance.userId,
      "session_id": sessionId,
    };
    String authUrl = constants.baseUrl + constants.createSessionEndpoint;
    Object data = jsonEncode(params);
    var response =
        await http.post(Uri.parse(authUrl), headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    return responseMap['statuscode'];
  }
}
