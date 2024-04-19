import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat/model/prompt_response.dart';
import 'package:gka/chat/repo/chat_repo.dart';
import 'package:gka/chat_bubble.dart';
import 'package:gka/shared/loading_view_model.dart';
import 'package:gka/text_to_speech.dart';
import 'package:gka/utils/app_state.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:uuid/uuid.dart';
import '../../login/model/login_api_response_model.dart' as login;
import '../../message_bubble.dart';
import '../../utils/network_utils.dart';
import '../../utils/util.dart';
import '../model/available_models.dart' as model;
import '../model/available_prompt_response_model.dart';

class ChatViewModel extends LoadingViewModel {
  ChatViewModel({
    required this.repo,
  });

  final ChatRepository repo;
  bool isFirstTime = true;
  String? sessionId;
  var scrollControllerListView = ScrollController();
  int prevChatLength = 0;

  // TextToSpeech tts = TextToSpeech();
  FlutterTts tts = FlutterTts();
  int responseCount = 1;
  String queryString = "";
  String llmType = '';
  TextEditingController chatController = TextEditingController();
  TextEditingController promptController = TextEditingController();
  TextEditingController intentController = TextEditingController();
  bool speechToTextOn = false;
  bool isVoiceInitiated = false;
  File? capturedPhoto;
  int timerCounter = 0;
  int loaderCounter = 0;
  List<MessageBubble> chatMessages = [];
  List<String> loaderMsgList = [
    'Please wait',
    'we are checking',
    'Looking for the result',
    'Hold on a moment',
    'Searching for results',
    'Gathering the data',
    'Just a moment'
  ];
  TextToSpeechService? textToSpeechService;
  MessageBubble? textToSpeechMessageBubble;
  String summaryData = "";
  bool displayUserText = false;
  bool isLoadingResponse = false;

  bool toggleValue = false;
  OverlayEntry? overlayEntry;
  late Timer periodicTimer;
  Timer? dataTimer;
  Timer? loadingTimer;
  String autoSessionId = '';
  String selectedModel = '';
  String selectedPromptModel = '';
  String selectedPromptModelUUID = '';

  final SpeechToText _speechToText = SpeechToText();
  ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);

  // ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  bool speechEnabled = false;
  Map<String, String> promptTemplateIntentMapping = {};
  Map<String, String> modelNameUuidMapping = {};
  List<String>? modelList = [];

  clearData() {
    promptTemplateIntentMapping.clear();
  }

  void updateSelectedModel(String value) {
    selectedModel = value;
    AppState.instance.modelName = value;
    AppState.instance.modelUUID = modelNameUuidMapping[value]!;
    notifyListeners();
  }

  updateSelectedModelForPrompt(String value) {
    selectedPromptModel = value;
    selectedPromptModelUUID = modelNameUuidMapping[value]!;
    notifyListeners();
  }

  Future<String?> createSession() async {
    try {
           String uuid = const Uuid().v4();
      sessionId = uuid;
      isFirstTime = true;
      notifyListeners();
      return uuid;
      String url = constants.genAiUrl;
      String data = AppState.instance.userData;
      /* Content data = login.Content(
        project_uuid: '6f86292b-dd9a-4987-bb8f-c3940263b349',
        username: "APWRIMS",
        userId: '44',
        firstName: 'APWRIMS',
        userDetailsJson: UserDetailsJson(
          data: login.Data(
            locType: 'mandal',
            location: login.Location(state: [
              login.State(
                  stateName: 'Andhra Pradesh',
                  stateUUID: "6f86292b-dd9a-4987-bb8f-c3940263b349",
                  district: [
                    login.District(
                        districtName: 'Srikakulam',
                        districtUUID: '00bb53a0-a27e-46c4-9016-fe9545766cb9',
                        mandal: [
                          login.Mandal(
                              mandalName: 'BURJA',
                              mndalUUID: '1437f9bf-207a-4d7e-bd9d-0af79b6ef8db')
                        ]),
                  ]),
            ]),
          ),
        ),
      );*/
      print("Request data before encode::$data");
      String requestBody = jsonEncode(data);
      http.Response response = await http.post(
        Uri.parse(url),
        body: data,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        print("sessionId:: ${jsonDecode(response.body)["session_id"]}");
        sessionId = jsonDecode(response.body)["session_id"];
        isFirstTime = false;
        notifyListeners();
        return sessionId;
      } else {
        Fluttertoast.showToast(msg: "Couldn't create Session");
      }
    } catch (error, stacktrace) {
      Fluttertoast.showToast(msg: "Couldn't create Session");
      print("Error Stacktrace $error $stacktrace");
    }
    return null;
  }

  void updateFirstTimeValue() {
    isFirstTime = true;
    notifyListeners();
  }

  Future? getAvailablePrompts(BuildContext context, String modelUUID) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        PromptResponseModel promptResponseModel =
            await repo.fetchPrompts(context, modelUUID);
        Map<String, String> promptTemplates = {};
        promptTemplateIntentMapping.clear();
        if (promptResponseModel.statusCode == 200 &&
            promptResponseModel.result == true) {
          if (promptResponseModel.response != null &&
              promptResponseModel.response?.length != 0) {
            for (int i = 0; i < promptResponseModel.response!.length; i++) {
              promptTemplates[promptResponseModel.response![i]
                  .promptTemplate!] = promptResponseModel.response![i].intent!;
            }
            isLoading = false;
            print("weweweww promptTemplateIntentMapping ${promptTemplates}");
            promptTemplateIntentMapping = promptTemplates;
            notifyListeners();
          } else {
            isLoading = false;
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return null;
  }

  Future? getAvailableTools(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        PromptResponseModel promptResponseModel =
            await repo.fetchTools(context);

        if (promptResponseModel.statusCode == 200 &&
            promptResponseModel.result == true) {
          if (promptResponseModel.response != null &&
              promptResponseModel.response?.length != 0) {
            for (int i = 0; i < promptResponseModel.response!.length; i++) {
              promptTemplateIntentMapping[promptResponseModel.response![i]
                  .promptTemplate!] = promptResponseModel.response![i].intent!;
            }
            isLoading = false;
            print(
                "weweweww promptTemplateIntentMapping ${promptTemplateIntentMapping}");
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return null;
  }

  Future<bool> createPrompt(
      BuildContext context, String prompt, String intent) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        ResponseModal responseModal =
            await repo.createPrompt(context, prompt, intent,selectedPromptModelUUID);
        if (responseModal.statusCode == 200 && responseModal.result == true) {
          isLoading = false;
          notifyListeners();
          return true;
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return false;
  }

  Future<bool> updatePrompt(
      BuildContext context, String prompt, String intent) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        ResponseModal responseModal =
            await repo.updatePrompt(context, prompt, intent);
        if (responseModal.statusCode == 200 && responseModal.result == true) {
          isLoading = false;
          notifyListeners();
          return true;
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return false;
  }

  Future? getAvailableModels(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        model.AvailabeModelResponse availabeModelResponse =
            await repo.fetchModels(context);

        if (availabeModelResponse.statusCode == 200 &&
            availabeModelResponse.result == true) {
          if (availabeModelResponse.response != null &&
              availabeModelResponse.response?.length != 0) {
            for (int i = 0; i < availabeModelResponse.response!.length; i++) {
              modelNameUuidMapping.addAll({
                availabeModelResponse.response![i].modelName!:
                    availabeModelResponse.response![i].modelUuid!
              });
              if (!modelList!
                  .contains(availabeModelResponse.response![i].modelName)) {
                modelList!.add(availabeModelResponse.response![i].modelName!);
              }
            }
            isLoading = false;
            print("weweweww modelNameUuidMapping ${modelNameUuidMapping}");
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return null;
  }
}
