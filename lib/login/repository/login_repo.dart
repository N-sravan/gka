import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gka/login/model/token_model.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_state.dart';
import '../model/login_api_response_model.dart';
import 'package:gka/utils/common_constants.dart' as constants;

/// Abstract class for the login repository
abstract class LoginRepository {
  Future<LoginResult> authenticate(
      Map<String, String> params, BuildContext context);

  Future<int?> saveFcmToken(BuildContext context);

  Future fetchCsrfToken(BuildContext context);
}

/// Concrete class implementation for the login repository
class LoginRepositoryImpl extends LoginRepository {
  @override
  Future<LoginResult> authenticate(
      Map<String, String> params, BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.loginEndpoint;
    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    LoginResult loginResult = LoginResult.fromJson(responseMap);
    return loginResult;
  }

  @override
  Future<int?> saveFcmToken(BuildContext context) async {
    Map<String, dynamic> params = {
      "fcmToken": AppState.instance.fcmToken,
      "userId": AppState.instance.userId,
      "locationUuid": AppState.instance.locUUID,
      "locationType": AppState.instance.locType,
      "locationName": AppState.instance.locName,
      "project_uuid": "6f86292b-dd9a-4987-bb8f-c3940263b349"
    };
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.saveFcmToken;
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
    String authUrl = constants.baseUrl + constants.csrfEndPoint;
    http.Response response = await http.get(
      Uri.parse(authUrl),
      headers: authHeaders,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    return responseMap;
  }
}
