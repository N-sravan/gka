import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;

import '../model/available_models.dart';
import '../model/token_response.dart';

/// Abstract class for the login repository
abstract class HomeRepository {
  Future<int?> deleteToken(BuildContext context);

  Future<AvailabeModelResponse> fetchModels(BuildContext context);
// Future<PromptResponseModel> fetchPrompts(BuildContext context);
}

/// Concrete class implementation for the login repository
class HomeRepositoryImpl extends HomeRepository {
  @override
  Future<int?> deleteToken(BuildContext context) async {
    Map<String, dynamic> params = {
      "fcmToken": AppState.instance.fcmToken,
      "project_uuid": "6f86292b-dd9a-4987-bb8f-c3940263b349"
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

  @override
  Future<AvailabeModelResponse> fetchModels(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "project_uuid": 'd19a5290-2e40-494a-83d2-98f4c845b1f1'
    };
    String authUrl = constants.ngrok + constants.getAvailabeModelsEndpoint;
    Uri url = Uri.parse(authUrl);
    String data = jsonEncode(params);
    var response = await http.post(url, headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    AvailabeModelResponse availabeModelResponse =
    AvailabeModelResponse.fromJson(responseMap);
    return availabeModelResponse;
  }

/* @override
  Future<PromptResponseModel> fetchPrompts(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.ngrok + constants.getAvailabePromptsEndpoint + '2a';
    Uri url = Uri.parse(authUrl);

    var response = await http.get(url, headers: authHeaders);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    PromptResponseModel promptResponseModel = PromptResponseModel.fromJson(responseMap);
    return promptResponseModel;
  }*/
}