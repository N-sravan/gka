import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/model/prompt_response.dart';
import 'package:gka/login/model/token_model.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;

import '../model/available_models.dart';
import '../model/available_prompt_response_model.dart';

/// Abstract class for the login repository
abstract class ChatRepository {
  Future<int?> deleteToken(BuildContext context);

  Future<PromptResponseModel> fetchPrompts(
      BuildContext context, String modelUUID);

  Future<ResponseModal> createPrompt(
      BuildContext context, String prompt, String intent, String modelUUID);

  Future<ResponseModal> updatePrompt(
      BuildContext context, String prompt, String intent);

  Future<PromptResponseModel> fetchTools(BuildContext context);

  Future<AvailabeModelResponse> fetchModels(BuildContext context);
}

/// Concrete class implementation for the login repository
class ChatRepositoryImpl extends ChatRepository {
  @override
  Future<int?> deleteToken(BuildContext context) async {
    Map<String, dynamic> params = {
      "fcmToken": AppState.instance.fcmToken,
      "project_uuid": constants.apwrimsUUID
    };
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.genAiBaseUrl + constants.deleteTokenEndpoint;
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
  Future<PromptResponseModel> fetchPrompts(
      BuildContext context, String modelUUID) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "project_uuid": constants.apwrimsUUID,
      "user_uuid": AppState.instance.userId,
      "model_uuid": modelUUID
    };

    String authUrl = constants.genAiBaseUrl + constants.getAvailabePromptsEndpoint;

    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    PromptResponseModel promptResponseModel =
        PromptResponseModel.fromJson(responseMap);
    return promptResponseModel;
  }

  @override
  Future<PromptResponseModel> fetchTools(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "proj_uuid": constants.apwrimsUUID,
      "user_uuid": AppState.instance.userId,
      "src_type": 'GET_API',
    };
    String authUrl = constants.genAiBaseUrl + constants.getToolsEndpoint;

    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    PromptResponseModel promptResponseModel =
        PromptResponseModel.fromJson(responseMap);
    return promptResponseModel;
  }

  @override
  Future<ResponseModal> createPrompt(BuildContext context, String promptMessage,
      String intent, String modelUUID) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "model_uuid": modelUUID,
      "prompt_template": promptMessage,
      "intent": intent,
      "user_uuid": AppState.instance.userId,
      "project_uuid": constants.apwrimsUUID
    };
    String authUrl = constants.genAiBaseUrl + constants.createPromptTemplateEndpoint;

    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    ResponseModal responseModal = ResponseModal.fromJson(responseMap);
    return responseModal;
  }

  @override
  Future<ResponseModal> updatePrompt(
      BuildContext context, String promptMessage, String intent) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "model_uuid": AppState.instance.modelUUID,
      "prompt_template": promptMessage,
      "intent": intent,
      "user_uuid": AppState.instance.userId,
      "project_uuid": constants.apwrimsUUID
    };
    String authUrl = constants.genAiBaseUrl + constants.updatePromptTemplateEndpoint;

    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    ResponseModal responseModal = ResponseModal.fromJson(responseMap);
    return responseModal;
  }

  @override
  Future<AvailabeModelResponse> fetchModels(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "project_uuid": constants.apwrimsUUID,
    };
    String authUrl = constants.genAiBaseUrl + constants.getAvailabeModelsEndpoint;
    String data = jsonEncode(params);
    var response =
        await http.post(Uri.parse(authUrl), headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    AvailabeModelResponse availabeModelResponse =
        AvailabeModelResponse.fromJson(responseMap);
    return availabeModelResponse;
  }
}
