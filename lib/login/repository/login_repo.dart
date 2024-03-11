import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_state.dart';
import '../model/login_api_response_model.dart';
import 'package:gka/utils/common_constants.dart' as constants;

/// Abstract class for the login repository
abstract class LoginRepository {

  Future<LoginResult> authenticate(Map<String, String> params, BuildContext context);

  Future fetchCsrfToken(BuildContext context);
}

/// Concrete class implementation for the login repository
class LoginRepositoryImpl extends LoginRepository {
  @override
  Future<LoginResult> authenticate(
      Map<String, String> params, BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerContentTypeFormUrl
    };
    String authUrl = constants.baseUrl + constants.loginEndpoint;
    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: params,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    LoginResult loginResult = LoginResult.fromJson(responseMap);
    loginResult.statusCode = response.statusCode;
    return loginResult;
  }

  @override
  Future fetchCsrfToken(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson,
      'Authorization' : 'Bearer ${AppState.instance.token}'
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
