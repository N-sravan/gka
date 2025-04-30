import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gka/chat/model/activity_status_response.dart';
import 'package:gka/chat/model/chat_history_model.dart';
import 'package:gka/chat/model/chat_message_history.dart';
import 'package:gka/chat/model/get_documents_response.dart';
import 'package:gka/chat/model/get_users_response.dart';
import 'package:http/http.dart' as http;
import '../../home/model/available_models.dart';
import '../../shared/token_response.dart';
import '../../utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../model/get_prompts_response.dart';
import '../model/get_tools_response_model.dart';
import '../model/prompt_submission_response.dart';
import '../model/user_session_model.dart';

/// Abstract class for the login repository
abstract class ChatRepository {
  Future<int?> deleteToken(BuildContext context);

  Future<int?> deleteTools(List<String> toolUUIDs);

  Future<int?> createOrUpdateTool();

  Future<GetAllPromptsResponseModel> fetchPrompts(
      BuildContext context, String modelUUID);

  Future<PromptSubmissionResponse> createPrompt(
      BuildContext context, String prompt, String intent, String modelUUID);

  Future<PromptSubmissionResponse> updatePrompt(
      BuildContext context, String prompt, String intent);

  Future<ToolInventoryResponseModel> fetchTools(BuildContext context);

  Future<AvailabeModelResponse> fetchModels(BuildContext context);

  Future<GetDocumentsResponseModel> fetchDocuments(BuildContext context);

  Future<ChatHistoryModel> fetchChatHistory(
      String sessionId, BuildContext context);

  Future<UserResponseModel> fetchUsers(BuildContext context);

  Future<List<ChatMessageHistory>> fetchMessageHistory(String sessionId);

  Future<List<ChatMessageHistory>> fetchSessionHistory();

  Future<UserSessionModel> fetchUserSessions();

  Future<bool> deleteDocument(BuildContext context, String docId);

  Future<bool> deleteSession(BuildContext context, String sessionId);

  Future<bool> updateSession(
      BuildContext context, String sessionId, String newId);

  Future<bool> deleteChunk(BuildContext context, String chunkId);

  Future<ActivityStatusResponse> submitActivityStatus(
      Map<String, dynamic> data, bool isIncreased);
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
      // "project_uuid": constants.projectId,
      "user_uuid": AppState.instance.userId,
    };
    String authUrl = constants.baseUrl + constants.getDocumentsEndpoint;
    String data = jsonEncode(params);
    var response =
        await http.post(Uri.parse(authUrl), headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    GetDocumentsResponseModel getDocumentsResponseModel =
        GetDocumentsResponseModel.fromJson(responseMap);
    return getDocumentsResponseModel;
  }

  @override
  Future<ChatHistoryModel> fetchChatHistory(
      String sessionId, BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, dynamic> params = {
      "user_id": AppState.instance.userId,
      "session_id": sessionId
    };
    String authUrl =
        'https://apaims2.0.vassarlabs.com/chatbot/chat/get-chat-history';
    // String authUrl = 'http://192.168.18.40:8000/chat/get-chat-history';
    Object data = jsonEncode(params);
    var response =
        await http.post(Uri.parse(authUrl), headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    ChatHistoryModel chatHistoryModel = ChatHistoryModel.fromJson(responseMap);
    return chatHistoryModel;
  }

  @override
  Future<UserResponseModel> fetchUsers(BuildContext context) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };

    Map<String, dynamic> params = {
      "admin_id": AppState.instance.userId,
    };
    String authUrl = constants.baseUrl + constants.getUsersDataEndpoint;
    String data = jsonEncode(params);
    var response =
        await http.post(Uri.parse(authUrl), headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    UserResponseModel userResponseModel =
        UserResponseModel.fromJson(responseMap);
    return userResponseModel;
  }

  @override
  Future<bool> deleteDocument(BuildContext context, String fileUUID) async {
    Map<String, dynamic> params = {"file_uuid": fileUUID};
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.baseUrl + constants.deleteFileEndpoint;
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

  @override
  Future<bool> deleteSession(BuildContext context, String sessionId) async {
    Map<String, dynamic> params = {
      "user_id": AppState.instance.userId,
      "session_ids": [sessionId]
    };
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.deleteSessionEndpoint;
    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    if (responseMap['statuscode'] == 200) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> updateSession(
      BuildContext context, String sessionId, String newId) async {
    Map<String, dynamic> params = {
      "user_id": AppState.instance.userId,
      "session_id": sessionId,
      "new_session_id": newId
    };
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.updateSessionEndpoint;
    String requestBody = jsonEncode(params);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    if (responseMap['statuscode'] == 200) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteChunk(BuildContext context, String chunkId) async {
    Map<String, dynamic> params = {"chunk_uuid": chunkId};
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = constants.baseUrl + constants.deleteChunkEndpoint;
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

  @override
  Future<ActivityStatusResponse> submitActivityStatus(
      Map<String, dynamic> body, bool isIncreased) async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    String authUrl = '';

    isIncreased
        ? constants.baseUrl + constants.increaseLimitEndpoint
        : constants.baseUrl + constants.decreaseLimitEndpoint;

    String requestBody = jsonEncode(body);

    http.Response response = await http.post(
      Uri.parse(authUrl),
      headers: authHeaders,
      body: requestBody,
    );
    Map<String, dynamic> responseMap = jsonDecode(response.body);

    ActivityStatusResponse activityStatusResponse =
        ActivityStatusResponse.fromJson(responseMap);

    return activityStatusResponse;
  }

  @override
  Future<List<ChatMessageHistory>> fetchMessageHistory(String sessionId) async {
    Map<String, String> authHeaders = {
      'Authorization': 'Bearer 2r9MjMpyFar4ySZh_KfGWzMcmqoUnQOnA9lMoFTG8Bg',
      'Accept': '*/*',
    };
/*    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson,
      'x-api-key': 'sk-wB4MAe1kOlMMRmdX0KfpwhwMNP8HaKjLnNdsiIdCtxc',
    };*/

    String encodedSessionId = Uri.encodeComponent(sessionId);
    String flowId = '4a5c8d41-51d7-4e81-85b8-377bb6a28043';
    String authUrl =
        "https://agentsbuilder.apaims2.0.vassarlabs.com/api/v1/chatmessage/$flowId?sessionId=$encodedSessionId";

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

  @override
  Future<List<ChatMessageHistory>> fetchSessionHistory() async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson,
    };

    String authUrl =
        'https://agentsbuilder.apaims2.0.vassarlabs.com/api/v1/monitor/messages?flow_id=34621397-d485-4d1b-ba04-480d3039a1c3';

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

  @override
  Future<UserSessionModel> fetchUserSessions() async {
    Map<String, String> authHeaders = {
      constants.headerContentType: constants.headerJson
    };
    Map<String, dynamic> params = {
      "user_id": AppState.instance.userId,
    };
    String authUrl =
        'https://apaims2.0.vassarlabs.com/chatbot/chat/get-sessions';
    String data = jsonEncode(params);
    var response =
        await http.post(Uri.parse(authUrl), headers: authHeaders, body: data);

    Map<String, dynamic> responseMap = jsonDecode(response.body);

    UserSessionModel userSessionModel = UserSessionModel.fromJson(responseMap);
    /* List<SessionHistoryModel> filteredData = userSessionModel.data
        .where((session) =>
            session.data != null && session.data.toString().trim().isNotEmpty)
        .toList();*/
    return userSessionModel;
  }
}
