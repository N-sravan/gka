import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gka/login/model/token_model.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;

/// Abstract class for the login repository
abstract class HomeRepository {
  Future<int?> deleteToken(BuildContext context);
}

/// Concrete class implementation for the login repository
class HomeRepositoryImpl extends HomeRepository {
  @override
  Future<int?> deleteToken(BuildContext context) async {
    Map<String, dynamic> params = {
      "fcmToken": AppState.instance.fcmToken,
    };
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.deleteToken;
    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    TokenResponse tokenResponse = TokenResponse.fromJson(responseMap);
    return tokenResponse.statusCode;
  }
}
