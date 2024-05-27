import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/model/get_documents_response.dart';
import 'package:http/http.dart' as http;
import '../../home/model/available_models.dart';
import '../../shared/token_response.dart';
import '../../utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../model/get_prompts_response.dart';
import '../model/get_tools_response_model.dart';
import '../model/prompt_submission_response.dart';

/// Abstract class for the login repository
abstract class ChatRepository {

  Future<int?> deleteToken(BuildContext context);

  Future<int?> deleteTools(List<String> toolUUIDs);

  Future<int?> createOrUpdateTool();

  Future<GetAllPromptsResponseModel> fetchPrompts(BuildContext context, String modelUUID);

  Future<PromptSubmissionResponse> createPrompt(BuildContext context, String prompt, String intent, String modelUUID);

  Future<PromptSubmissionResponse> updatePrompt(BuildContext context, String prompt, String intent);

  Future<ToolInventoryResponseModel> fetchTools(BuildContext context);

  Future<AvailabeModelResponse> fetchModels(BuildContext context);

  Future<GetDocumentsResponseModel> fetchDocuments(BuildContext context);

  Future<bool> deleteDocument(BuildContext context, String chunkId);

}

/// Concrete class implementation for the login repository
class ChatRepositoryImpl extends ChatRepository {
  @override
  Future<int?> deleteToken(BuildContext context) async {
    Map<String, dynamic> params = {
      "fcmToken": AppState.instance.fcmToken,
      "project_uuid": constants.projectId
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
  Future<int?> deleteTools(List<String> toolUUIDs) async {
    Map<String, dynamic> params = {"tool_uuids": toolUUIDs};
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
  Future<GetAllPromptsResponseModel> fetchPrompts(
      BuildContext context, String modelUUID) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "project_uuid": constants.projectId,
      "user_uuid": AppState.instance.userId,
      "model_uuid": modelUUID
    };

    String authUrl =
        constants.genAiBaseUrl + constants.getAvailabePromptsEndpoint;

    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    GetAllPromptsResponseModel getAllPromptsResponseModel =
        GetAllPromptsResponseModel.fromJson(responseMap);
    return getAllPromptsResponseModel;
  }

  @override
  Future<ToolInventoryResponseModel> fetchTools(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "proj_uuid": constants.projectId,
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

    ToolInventoryResponseModel toolInventoryResponseModel =
        ToolInventoryResponseModel.fromJson(responseMap);
    return toolInventoryResponseModel;
  }

  @override
  Future<PromptSubmissionResponse> createPrompt(BuildContext context,
      String promptMessage, String intent, String modelUUID) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "model_uuid": modelUUID,
      "prompt_template": promptMessage,
      "intent": intent,
      "user_uuid": AppState.instance.userId,
      "project_uuid": constants.projectId
    };
    String authUrl =
        constants.genAiBaseUrl + constants.createPromptTemplateEndpoint;

    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    PromptSubmissionResponse promptSubmissionResponse =
        PromptSubmissionResponse.fromJson(responseMap);
    return promptSubmissionResponse;
  }

  @override
  Future<int?> createOrUpdateTool() async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      /* "model_uuid": modelUUID,
      "prompt_template": promptMessage,
      "intent": intent,
      "user_uuid": AppState.instance.userId,
      "project_uuid": constants.projectId*/
    };
    String authUrl =
        constants.genAiBaseUrl + constants.createPromptTemplateEndpoint;

    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    PromptSubmissionResponse promptSubmissionResponse =
        PromptSubmissionResponse.fromJson(responseMap);
    return 1;
  }

  @override
  Future<PromptSubmissionResponse> updatePrompt(
      BuildContext context, String promptMessage, String intent) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {
      "model_uuid": AppState.instance.modelUUID,
      "prompt_template": promptMessage,
      "intent": intent,
      "user_uuid": AppState.instance.userId,
      "project_uuid": constants.projectId
    };
    String authUrl =
        constants.genAiBaseUrl + constants.updatePromptTemplateEndpoint;

    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    PromptSubmissionResponse promptSubmissionResponse =
        PromptSubmissionResponse.fromJson(responseMap);
    return promptSubmissionResponse;
  }

  @override
  Future<AvailabeModelResponse> fetchModels(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, String> params = {"project_uuid": constants.projectId};
    String authUrl =
        constants.genAiBaseUrl + constants.getAvailabeModelsEndpoint;
    String data = jsonEncode(params);
    var response =
        await http.post(Uri.parse(authUrl), headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    AvailabeModelResponse availabeModelResponse =
        AvailabeModelResponse.fromJson(responseMap);
    return availabeModelResponse;
  }

  @override
  Future<GetDocumentsResponseModel> fetchDocuments(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, dynamic> params = {
      "project_uuid": constants.projectId,
      "user_uuid":
          AppState.instance.mode == 'user' ? AppState.instance.userId : 'null',
      "metadata": {},
      "threshold": 0
    };
    String authUrl = constants.genAiBaseUrl + constants.getFilesEndPoint;
    String data = jsonEncode(params);
    var response = await http.post(Uri.parse(authUrl), headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    GetDocumentsResponseModel getDocumentsResponseModel =
        GetDocumentsResponseModel.fromJson(responseMap);
    return getDocumentsResponseModel;
  }

  @override
  Future<bool> deleteDocument(BuildContext context, String chunkId) async {
    Map<String, dynamic> params = {
      "project_uuid": constants.projectId,
      "chunk_id": chunkId
    };
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.genAiBaseUrl + constants.deleteFileEndPoint;
    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    if (responseMap['statusCode'] == 200) {
      return true;
    }
    return false;
  }
}
