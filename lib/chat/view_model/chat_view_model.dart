import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat/model/chat_history_model.dart';
import 'package:gka/chat/model/chat_message_history.dart';
import 'package:gka/chat/model/get_documents_response.dart';
import 'package:gka/chat/model/get_users_response.dart';
import 'package:gka/shared/loading_view_model.dart';
import 'package:gka/utils/app_state.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import '../../home/model/available_models.dart' as model;
import '../../login/model/login_api_response_model.dart' as login;
import '../../message_bubble.dart';
import '../../services/api_provider.dart';
import '../../utils/network_utils.dart';
import '../../utils/util.dart';
import '../model/activity_status_response.dart';
import '../model/get_prompts_response.dart';
import '../model/get_tools_response_model.dart';
import '../model/prompt_submission_response.dart';
import '../model/user_session_model.dart';
import '../repo/chat_repo.dart';

class ChatViewModel extends LoadingViewModel {
  ChatViewModel({
    required this.repo,
  });

  final ChatRepository repo;
  bool isFirstTime = true;
  String? sessionId;
  var scrollControllerListView = ScrollController();
  int prevChatLength = 0;

  int responseCount = 1;
  String queryString = "";
  String llmType = '';
  File? selectedFile;
  bool isUploading = false;
  String userActivity = '';
  TextEditingController chatController = TextEditingController();
  TextEditingController promptController = TextEditingController();
  TextEditingController intentController = TextEditingController();
  TextEditingController toolNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController sourceTypeController = TextEditingController();
  TextEditingController projectNameController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController variableNameController = TextEditingController();
  TextEditingController isMandatoryController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController defaultValueController = TextEditingController();
  TextEditingController filterIsMandatoryController = TextEditingController();
  TextEditingController filterVariableNameController = TextEditingController();
  TextEditingController filterValueController = TextEditingController();
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
  String fileUUID = '';

  final SpeechToText _speechToText = SpeechToText();
  ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);

  // ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  bool speechEnabled = false;
  Map<String, String> promptTemplateIntentMapping = {};
  Map<String, List<FileResponse>> documentIdTextMapping = {};
  List<User> usersList = [];
  List<ChatData> chatDataList = [];
  Map<String, String> sessionIdDataMapping = {};
  Map<String, String> toolNameDescriptionMapping = {};
  Map<String, String> modelNameUuidMapping = {};
  Map<String, String> messageTimestampMapping = {};
  List<String>? modelList = [];
  List<String>? toolUUIDs = [];
  List<FileResponse>? documentsList = [];
  DateFormat formatter = DateFormat("dd-MM-yyyy");
  bool _speechEnabled = false;
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  ValueNotifier<bool> showAllStepsExpanded = ValueNotifier(false);
  ValueNotifier<bool> expandAllSteps = ValueNotifier(false);
  String tempStreamingText = '';

  // API constants
  static const String bearerToken =
      '2r9MjMpyFar4ySZh_KfGWzMcmqoUnQOnA9lMoFTG8Bg';

  int start = 0;
  int end = 0;
  bool hasSpoken = false;
  String? _newVoiceText;
  int prevChatLengthHistory = 0;
  int c = 0;
  String highlightedText = "";
  String remainingText = "";
  bool isllmDropdown = false;
  final List<Map<String, dynamic>> messages = [];
  String url = '';
  IOWebSocketChannel? channel;
  late ChatViewModel viewModel;

  List<String> langLoaderMsgList = [];
  List<String> llmOptionsList = ['chatgpt-4o', 'gemma2:9b', 'deepseek-r1'];
  List<String> langList = ['English', 'Telugu'];

  Map<String, String> currentVoice = {
    "name": "en-us-x-iom-local",
    "locale": "en-US"
  };
  String language = '';
  String langId = '';
  String dataNotFoundMsg = '';
  String? llmSelected;
  String? langSelected;

  // UI state notifiers
  ValueNotifier<bool> isStreaming = ValueNotifier<bool>(false);
  ValueNotifier<String> streamingText = ValueNotifier<String>("");
  ValueNotifier<bool> showAgentSteps = ValueNotifier<bool>(true);

  // Agent steps data
  List<Map<String, dynamic>> agentSteps = [];

  // List<Map<String, dynamic>> currentSteps = [];
  List<Map<String, dynamic>> currentSteps = [];
  Map<String, String> contentBlocksData = {};
  List<Map<String, dynamic>> gatheredSteps = [];

  // Debug data
  List<String> debugSseEvents = [];

  // API configuration
  final Map<String, String> apiConfig = {
    "baseUrl": "https://agentsbuilder.apaims2.0.vassarlabs.com",
    "flowId": "d38adaab-877c-4a47-a35c-047affbf1102",
    "apiKey": "sk-kzSs-5jk4A7J_8JBqvCX5iaF2miwKuexm1_FIcPLuCw"
  };

  // Update API configuration
  void updateApiConfig({String? baseUrl, String? flowId, String? apiKey}) {
    if (baseUrl != null) apiConfig["baseUrl"] = baseUrl;
    if (flowId != null) apiConfig["flowId"] = flowId;
    if (apiKey != null) apiConfig["apiKey"] = apiKey;
  }

  late DatabaseReference ref;

  clearData() {
    promptTemplateIntentMapping.clear();
    chatController.clear();
    chatDataList.clear();
    messages.clear();
    selectedFile = null;
    isUploading = false;
    agentSteps = [];
    debugSseEvents = [];
    isStreaming.value = false;
    showLoader.value = false;
    streamingText.value = "";
    notifyListeners();
  }

  void toggleAgentSteps() {
    showAgentSteps.value = !showAgentSteps.value;
    notifyListeners();
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

  Future? getAvailablePrompts(BuildContext context, String modelUUID) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        GetAllPromptsResponseModel getAllPromptsResponseModel =
            await repo.fetchPrompts(context, modelUUID);
        Map<String, String> promptTemplates = {};
        promptTemplateIntentMapping.clear();
        if (getAllPromptsResponseModel.statusCode == 200 &&
            getAllPromptsResponseModel.result == true) {
          if (getAllPromptsResponseModel.response != null &&
              getAllPromptsResponseModel.response?.length != 0) {
            for (int i = 0;
                i < getAllPromptsResponseModel.response!.length;
                i++) {
              promptTemplates[
                      getAllPromptsResponseModel.response![i].promptTemplate!] =
                  getAllPromptsResponseModel.response![i].intent!;
            }
            isLoading = false;
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

  Future? getUsersList(BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        UserResponseModel userResponseModel = await repo.fetchUsers(context);
        usersList.clear();
        if (userResponseModel.statusCode == 200) {
          if (userResponseModel.users != null) {
            userResponseModel.users!.forEach((key, value) {
              usersList.add(value);
            });
            isLoading = false;
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
            .logMessage('Chat View Model', 'Error while authenticating $e');
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

  Future? getDocuments(BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        GetDocumentsResponseModel getDocumentsResponseModel =
            await repo.fetchDocuments(context);
        documentIdTextMapping.clear();
        if (getDocumentsResponseModel.statusCode == 200) {
          if (getDocumentsResponseModel.response != null) {
            getDocumentsResponseModel.response.forEach((key, value) {
              if (value.isNotEmpty) {
                documentIdTextMapping[key] = value;
                fileUUID = value[0].fileUUID!;
              }
            });
            print("weweweww documentIdMapping $documentIdTextMapping");
            isLoading = false;
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
            .logMessage('Chat View Model', 'Error while authenticating $e');
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
        ToolInventoryResponseModel toolInventoryResponseModel =
            await repo.fetchTools(context);

        if (toolInventoryResponseModel.statusCode == 200 &&
            toolInventoryResponseModel.result == true) {
          if (toolInventoryResponseModel.response != null &&
              toolInventoryResponseModel.response!.isNotEmpty) {
            for (int i = 0;
                i < toolInventoryResponseModel.response!.length;
                i++) {
              toolNameDescriptionMapping[toolInventoryResponseModel.response![i]
                  .name!] = toolInventoryResponseModel.response![i].desc!;
            }
            isLoading = false;
            print(
                "weweweww toolNameDescriptionMapping $toolNameDescriptionMapping");
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
        PromptSubmissionResponse responseModal = await repo.createPrompt(
            context, prompt, intent, selectedPromptModelUUID);
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
        PromptSubmissionResponse promptSubmissionResponse =
            await repo.updatePrompt(context, prompt, intent);
        if (promptSubmissionResponse.statusCode == 200 &&
            promptSubmissionResponse.result == true) {
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

  Future<bool> deleteTool(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        int? result = await repo.deleteTools(toolUUIDs!);
        if (result != null && result == true) {
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
        Util.instance.logMessage('Chat Model', 'Error : $e');
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

  Future<bool> deleteDocument(BuildContext context, String docName) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        bool? result = await repo.deleteDocument(context, docName);
        if (result == true) {
          await getDocuments(context);
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
        Util.instance.logMessage('Chat View Model', 'Error : $e');
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

  Future<bool> deleteSession(BuildContext context, String sessionId) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        bool? result = await repo.deleteSession(context, sessionId);
        if (result == true) {
          await getSessionsForUser(context);
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
        Util.instance.logMessage('Chat View Model', 'Error : $e');
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

  Future<bool> updateSessionId(
      BuildContext context, String sessionId, String newId) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        bool? result = await repo.updateSession(context, sessionId, newId);
        if (result == true) {
          await getSessionsForUser(context);
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
        Util.instance.logMessage('Chat View Model', 'Error : $e');
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

  Future<bool> deleteChunk(BuildContext context, String chunkId) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        bool? result = await repo.deleteChunk(context, chunkId);
        if (result == true) {
          await getDocuments(context);
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
        Util.instance.logMessage('Chat View Model', 'Error : $e');
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

  Future<bool> createOrUpdateTool(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        int? result = await repo.createOrUpdateTool();
        if (result != null && result == true) {
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
        Util.instance.logMessage('Chat Model', 'Error : $e');
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

  fetchNotificationData() async {
    isLoading = true;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("CHAT_BOT_ALERT/HOURLY_NOTIFICATION/${constants.projectId}");
    int c = 0;

    await ref.orderByKey().limitToLast(5).once().then((event) async {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        dynamic values = snapshot.value;
        values.forEach((key, value) async {
          String responseMessage = '';
          int timeStamp = 0;
          if (value['isUser'] == false) {
            responseMessage = value['message'].toString();
            timeStamp = value['timestamp'];
          }
          if (responseMessage.isNotEmpty) {
            // Convert the timestamp to a DateTime object
            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);

            // Print the DateTime object
            print("Date and Time: $dateTime");

            // Format the DateTime object to a readable format
            String formattedDate = formatDateTime(dateTime);
            print("Formatted Date and Time: $formattedDate");
            messageTimestampMapping[formattedDate] = responseMessage;
          }
        });
      }
    });
    isLoading = false;
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      selectedFile = File(result.files.single.path!);
      isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadFile(BuildContext context) async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
      return false;
    } else {
      isUploading = true;
      notifyListeners();
      bool? value = await uploadDocument(context, selectedFile!.path);
      isUploading = false;
      notifyListeners();
      if (value != null && value) {
        Fluttertoast.showToast(msg: "Document uploaded successfully!");
        notifyListeners();
        return true;
      } else {
        Fluttertoast.showToast(msg: "Couldn\'t upload the document!");
        return false;
      }
    }
  }

  Future<bool?> uploadDocument(BuildContext context, String path) async {
    if (await networkUtils.hasActiveInternet()) {
      try {
        Map<String, String> params = {
          // "project_uuid": constants.projectId,
          "user_uuid": AppState.instance.userId,
          // "metadata": "{}"
        };
        bool result =
            await ApiProvider.instance.uploadMedia(params, path, 'file');
        if (result != null && result) {
          return true;
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: constants.genericErrorMsg, toastLength: Toast.LENGTH_LONG);
      }
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: constants.noNetworkAvailability, toastLength: Toast.LENGTH_LONG);
    }
    notifyListeners();
    return false;
  }

  Future<bool?> submitActivityStatus(
      BuildContext context, String text, bool isIncreased) async {
    if (await networkUtils.hasActiveInternet()) {
      try {
        isLoading = true;
        Map<String, dynamic> params = {};
        isIncreased
            ? params = {
                "user_id": AppState.instance.userId,
                "increased_limit": int.parse(text),
              }
            : params = {
                "user_id": AppState.instance.userId,
                "decreased_limit": int.parse(text),
              };
        ActivityStatusResponse activityStatusResponse =
            await repo.submitActivityStatus(params, isIncreased);
        if (activityStatusResponse != null) {
          if (activityStatusResponse.statusCode == 200) {
            return true;
          }
          return false;
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: constants.genericErrorMsg, toastLength: Toast.LENGTH_LONG);
      }
    } else {
      Navigator.pop(context);
      Fluttertoast.showToast(
          msg: constants.noNetworkAvailability, toastLength: Toast.LENGTH_LONG);
    }
    notifyListeners();
    isLoading = false;
    return false;
  }

  String formatDateTime(DateTime dateTime) {
    // Define the desired format
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');

    // Create the formatted string
    return "$day-$month-$year $hour:$minute:$second";
  }

  updateActivityStatus(String? newValue) {
    userActivity = newValue!;
  }

  /* Future? getChatHistoryForSession(
      String sessionId, BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        ChatHistoryModel chatHistoryModel =
            await repo.fetchChatHistory(sessionId, context);
        chatDataList.clear();
        if (chatHistoryModel.status == 200) {
          if (chatHistoryModel.data.isNotEmpty) {
            for (SessionHistoryModel item in chatHistoryModel.data) {
              ChatData chatData = ChatData(
                isUser: item.data['is_user'],
                message: item.data['message'],
              );
              chatDataList.add(chatData);
            }
            isLoading = false;
            notifyListeners();
          } else {
            isLoading = false;
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.genericErrorMsg),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance.logMessage('Chat View Model', 'Error $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return null;
  }*/

  Future<bool>? getMessageHistoryForSession(
      String sessionId, BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        List<ChatMessageHistory> chatMessageHistoryList =
            await repo.fetchMessageHistory(sessionId);
        chatDataList.clear();
        messages.clear();
        chatMessageHistoryList.sort((a, b) {
          // Compare timestamps first
          int cmp = a.timestamp.compareTo(b.timestamp);
          if (cmp != 0) return cmp;

          // If timestamps are the same, prioritize "User" before others
          if (a.sender == "User" && b.sender != "User") return -1;
          if (a.sender != "User" && b.sender == "User") return 1;

          return 0;
        });
        if (chatMessageHistoryList != null &&
            chatMessageHistoryList.isNotEmpty) {
          for (ChatMessageHistory item in chatMessageHistoryList) {
            String text = item.text
                .replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '')
                .trim();

            ChatData chatData = ChatData(
              isUser: item.sender == "User" ? true : false,
              message: text,
            );
            chatDataList.add(chatData);
            messages.add({
              'text': text,
              'is_user': item.sender == "User" ? true : false,
              'timestamp': item.timestamp
            });
          }
        }
        isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance.logMessage('Chat View Model', 'Error $e');
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

  Future<bool>? getStreamResponse(
      String sessionId, BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        List<ChatMessageHistory> chatMessageHistoryList =
            await repo.fetchMessageHistory(sessionId);
        chatDataList.clear();
        messages.clear();
        if (chatMessageHistoryList.isNotEmpty) {
          for (ChatMessageHistory item in chatMessageHistoryList) {
            ChatData chatData = ChatData(
              isUser: item.sender == "User" ? true : false,
              message: item.text,
            );
            chatDataList.add(chatData);
            messages.add({
              'text': item.text,
              'is_user': item.sender == "User" ? true : false,
              'timestamp': item.timestamp
            });
          }
          ;
        }
        isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance.logMessage('Chat View Model', 'Error $e');
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

  Future? getSessionsForUser(BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        UserSessionModel userSessionModel = await repo.fetchUserSessions();
        sessionIdDataMapping.clear();
        if (userSessionModel.status == 200) {
          if (userSessionModel.data.isNotEmpty) {
            userSessionModel.data.sort((a, b) => DateTime.parse(b.insertTs)
                .compareTo(DateTime.parse(a.insertTs)));
            for (var item in userSessionModel.data) {
              // String formattedId = parseFormattedSession(item.sessionId);
              sessionIdDataMapping[item.sessionId] = item.insertTs;
            }
            print("sessionIdDataMapping::${sessionIdDataMapping}");
            isLoading = false;
            notifyListeners();
          } else {
            isLoading = false;
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.genericErrorMsg),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance.logMessage('Chat View Model', 'Error $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
  }

  Future? getSessionHistory(String sessionId, BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        List<ChatMessageHistory> chatMessageHistoryList =
            await repo.fetchMessageHistory(sessionId);
        chatDataList.clear();
        if (chatMessageHistoryList != null &&
            chatMessageHistoryList.isNotEmpty) {
          if (chatMessageHistoryList.isNotEmpty) {
            for (ChatMessageHistory item in chatMessageHistoryList) {
              ChatData chatData = ChatData(
                isUser: item.sender == "User" ? true : false,
                message: item.text,
              );
              chatDataList.add(chatData);
            }
            isLoading = false;
            notifyListeners();
          } else {
            isLoading = false;
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.genericErrorMsg),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance.logMessage('Chat View Model', 'Error $e');
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

  String parseFormattedSession(String session) {
    final raw = session.replaceFirst('Session ', '');
    final normalized = raw.replaceFirst('-', ' ').replaceAll('_', ':');
    String format = DateFormat('MMM dd HH:mm:ss').parse(normalized).toString();
    return format;
  }

  bool get isConnected => channel != null && channel!.closeCode == null;

  initWebsocketConnection(BuildContext context) async {
    if (isConnected) {
      print("WebSocket already connected");
      return;
    }
    await initDeviceId();
    try {
      channel = IOWebSocketChannel.connect(url);
      channel!.stream.listen(
        (data) async {
          try {
            final decoded = jsonDecode(data);
            var result = decoded['message'];
            final isUser = decoded['is_user'];
            print("Received result: $result");

            // Remove <think>...</think> content
            result = result
                .replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '')
                .trim();

            print("Formatted result: $result");
            String translatedText = '';
            if (!AppState.instance.isEnglish) {
              Map<String, dynamic> data = await repo.translateText(
                  context, result, 'english', 'telugu');
              if (data['statuscode'] == 200) {
                translatedText = data['response'];
              }
            }
            print("Translated Text : $translatedText");
            messages.add({
              'text': AppState.instance.isEnglish ? result : translatedText,
              'is_user': isUser,
            });
            showLoader.value = false;
          } catch (e) {
            print("Error decoding JSON: $e");
            Fluttertoast.showToast(msg: 'Something went wrong');
            showLoader.value = false;
          }
        },
        onError: (error) {
          print("WebSocket stream error: $error");
          Fluttertoast.showToast(msg: 'WebSocket connection error');
          showLoader.value = false;
        },
        onDone: () {
          print("WebSocket connection closed");
          Fluttertoast.showToast(msg: 'WebSocket connection closed');
          showLoader.value = false;
        },
      );
    } catch (e) {
      print("Failed to connect to WebSocket: $e");
      Fluttertoast.showToast(msg: 'Failed to connect to server');
      showLoader.value = false;
    }
  }

  Future<void> initDeviceId() async {
    String deviceId = const Uuid().v4();

    url = 'wss://apaims2.0.vassarlabs.com/chatbot/ws/chat/$deviceId';
    print("12345 Generated Device ID: $deviceId");
    print("12345 Web socket URL: $url");
  }

  void stopListening() async {
    bool active = _speechToText.isListening;
    listeningActive.value = active;
    notifyListeners();
  }

  // Send a message and process streaming response
  Future<void> sendMessage(BuildContext context, String message) async {
    if (message.isEmpty) return;

    // Add user message to conversation
    final userMessage = {
      'is_user': true,
      'text': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    messages.add(userMessage);
    chatController.clear();
    showLoader.value = false;

    // Start streaming process
    isStreaming.value = true;
    streamingText.value = "Thinking..._";
    currentSteps = [];
    showAgentSteps.value = false;

    notifyListeners();

    // Make API request
    await _streamResponse(message);
  }

// Process streaming response from the API
  Future<void> _streamResponse(String userInput) async {
    final apiUrl =
        "https://agentsbuilder.apaims2.0.vassarlabs.com/api/v1/run/d38adaab-877c-4a47-a35c-047affbf1102?stream=true";
    final headers = {
      "Content-Type": "application/json",
      "accept": "text/event-stream",
      "x-api-key": "sk-kzSs-5jk4A7J_8JBqvCX5iaF2miwKuexm1_FIcPLuCw",
    };
    final payload = {
      "input_value": userInput,
      "session_id": AppState.instance.sessionId,
      "input_type": "chat",
      "output_type": "chat",
      "tweaks": null,
    };

    final client = http.Client();
    String finalText = "";
    final List<Map<String, dynamic>> stepsForThisMessage = [];

    try {
      final request = http.Request('POST', Uri.parse(apiUrl));
      request.headers.addAll(headers);
      request.body = json.encode(payload);

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        streamingText.value =
            "Error: Server returned ${streamedResponse.statusCode}";
        return;
      }

      final stream = streamedResponse.stream.transform(utf8.decoder);
      String buffer = '';

      await for (final chunk in stream) {
        buffer += chunk;

        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          debugSseEvents.add(trimmed);

          try {
            final dynamic data = json.decode(trimmed);
            if (data is! Map<String, dynamic>) continue;

            final eventType = data['event'] ?? 'data';
            final eventData = data['data'];

            if (eventType == 'add_message') {
              Map<String, dynamic>? msgData = eventData;

              if (msgData != null &&
                  (msgData['sender_name'] == 'Agent' ||
                      msgData['sender_name'] == 'AI')) {
                final contentBlocks = msgData['content_blocks'] ?? [];
                if (contentBlocks.isNotEmpty) {
                  _processContentBlocks(contentBlocks, stepsForThisMessage);
                  for (var block in contentBlocks) {
                    final contents = block['contents'] ?? [];

                    for (var content in contents) {
                      final header = content['header'];
                      if (header != null && header['title'] == 'Output') {
                        finalText = content['text'];
                        streamingText.value = finalText;
                        print('Output: $finalText');
                        break;
                      }
                    }
                  }
                }
              }
            }

            if (eventType == 'end' &&
                streamingText.value == "Thinking..._" &&
                finalText.isNotEmpty) {
              final outputs = eventData['result']?['outputs'];
              if (outputs != null && outputs is List && outputs.isNotEmpty) {
                final outputData = outputs[0]?['outputs'];
                if (outputData != null &&
                    outputData is List &&
                    outputData.isNotEmpty) {
                  final messageData =
                      outputData[0]?['results']?['message']?['data'];
                  if (messageData != null) {
                    final textContent = messageData['text'] ?? '';
                    if (textContent.isNotEmpty) {
                      finalText = textContent;
                      streamingText.value = finalText;

                      if (!_hasStepWithTitle(currentSteps, 'Output')) {
                        currentSteps.add({
                          'title': 'Output',
                          'type': 'Output',
                          'content': textContent,
                        });
                      } else {
                        final outputIndex = currentSteps
                            .indexWhere((step) => step['title'] == 'Output');
                        if (outputIndex != -1) {
                          currentSteps[outputIndex]['content'] =
                              textContent;
                        }
                      }
                    }
                  }
                }
              }
            }
          } catch (e) {
            debugPrint('⚠️ SSE JSON parse error: $e\nLine: $trimmed');
          }
        }
      }
      final contentBlocks = extractContentBlocks(currentSteps);
      // Final save of message
      if (finalText.isNotEmpty) {
        messages.add({
          'timestamp': DateTime.now().toIso8601String(),
          'text': finalText,
          'is_user': false,
          'expandContentBlocks': true,
          'content_blocks': contentBlocks,
        });
      }

      if (messages.length >= 2) {
        final prevMessageIndex = messages.length - 2;
        if (messages[prevMessageIndex]['is_user'] == true) {
          messages[prevMessageIndex]['content_blocks'] = contentBlocks;
        }
      }
      isStreaming.value = false;
    } catch (e) {
      streamingText.value = "Error: $e";
    } finally {
      isStreaming.value = false;
      client.close();
      notifyListeners();
    }
  }

// Process content blocks from the streaming response
  void _processContentBlocks(
      List<dynamic> contentBlocks, List<Map<String, dynamic>> gatheredSteps) {
    for (final block in contentBlocks) {
      if (block is Map<String, dynamic>) {
        final title = block['title'] ?? '';
        final contents = block['contents'] ?? [];

        if (title == 'Agent Steps') {
          _processAgentSteps(contents, gatheredSteps);
        } else if (title.isNotEmpty) {
          _processGenericContentBlock(title, contents);
        }
      }
    }

    notifyListeners();
  }

// Process agent steps specifically
  void _processAgentSteps(
      List<dynamic> steps, List<Map<String, dynamic>> gatheredSteps) {
    for (final step in steps) {
      if (step is Map<String, dynamic>) {
        final stepKey = _generateStepKey(step);

        if (!_stepExistsByKey(gatheredSteps, stepKey)) {
          gatheredSteps.add({...step, 'key': stepKey});
          Map<String, dynamic> uiStep = {};

          final duration = step['duration'] ?? 0;
          String durationStr = '';
          if (duration >= 1000) {
            durationStr = '${(duration / 1000).toStringAsFixed(1)}sec';
          } else {
            durationStr = '${duration}sec';
          }

          if (step['type'] == 'text') {
            final title = step['header']?['title'] ?? 'Text';
            final label = '$title - (Duration $durationStr)';
            uiStep[label] = step['text'];
            currentSteps.add(uiStep);
          }

          if (step['type'] == 'tool_use') {
            if (step.containsKey('tool_input') &&
                step['tool_input'] != null &&
                (step['tool_input'] as Map).isNotEmpty) {
              final label = 'Tool Input - (Duration $durationStr)';
              print("step tool input :${step['tool_input']}");
              uiStep[label] = step['tool_input'];
              currentSteps.add({...uiStep});
            }

            if (step.containsKey('output') && step['output'] != null) {
              uiStep = {};
              final label = 'Tool Output - (Duration $durationStr)';
              uiStep[label] = step['output'];
              currentSteps.add(uiStep);
            }
          }

          print("currentSteps ${currentSteps}");
        }
      }
    }
  }

// Process generic content blocks
  void _processGenericContentBlock(String title, List<dynamic> contents) {
    // Check if we already have this title in our steps
    final existingIndex =
        currentSteps.indexWhere((step) => step['title'] == title);

    if (contents.isNotEmpty) {
      // Extract content text from the first content item
      String content = '';
      if (contents[0] is Map<String, dynamic>) {
        content = contents[0]['text'] ?? contents[0]['content'] ?? '';
      } else if (contents[0] is String) {
        content = contents[0];
      }

      if (existingIndex != -1) {
        // Update existing step
        currentSteps[existingIndex]['content'] = content;
      } else {
        // Add new step
        currentSteps.add({
          'title': title,
          'type': 'text',
          'content': content,
        });
      }
    }
  }

// Generate unique key for a step
  String _generateStepKey(Map<String, dynamic> step) {
    final type = step['type'] ?? step['name'] ?? '';
    final text = step['text'] ?? step['content'] ?? '';
    return '$type:${text.hashCode}';
  }

// Check if step exists by key
  bool _stepExistsByKey(List<Map<String, dynamic>> steps, String key) {
    return steps.any((step) => step['key'] == key);
  }

// Check if step with title exists
  bool _hasStepWithTitle(List<Map<String, dynamic>> steps, String title) {
    return steps.any((step) => step['title'] == title);
  }

// Original _stepExists can stay as a fallback
  bool _stepExists(
      List<Map<String, dynamic>> steps, Map<String, dynamic> step) {
    if (steps.isEmpty) return false;

    return steps.any((existingStep) =>
        existingStep['type'] == step['type'] &&
        (existingStep['text'] == step['text'] ||
            existingStep['name'] == step['name']));
  }

  /*Future<void> sendMessage(BuildContext context, String message) async {
    String translatedText = '';
    if (!AppState.instance.isEnglish) {
      Map<String, dynamic> data =
          await repo.translateText(context, message, 'telugu', 'english');
      if (data['statuscode'] == 200) {
        translatedText = data['response'];
      }
    }
    print("Translated Text : $message");
    final messageJson = jsonEncode({
      'message': AppState.instance.isEnglish ? message : translatedText,
      'user_id': AppState.instance.userId,
      'session_id': AppState.instance.sessionId,
      'is_user': true,
    });

    print("Input data::$messageJson");
    channel!.sink.add(messageJson);
    messages.add({
      'text': message,
      'is_user': true,
    });
    chatController.clear();
    showLoader.value = true;
    notifyListeners();
  }*/

  Future<void> sendMessageStream(String userMessage, String? sessionId) async {
    String apiKey = 'sk-wB4MAe1kOlMMRmdX0KfpwhwMNP8HaKjLnNdsiIdCtxc';
    String flowId = 'd38adaab-877c-4a47-a35c-047affbf1102';
    String domain = 'agentsbuilder.apaims2.0.vassarlabs.com';
    messages.add({
      'text': userMessage,
      'is_user': true,
    });
    chatController.clear();
    showLoader.value = true;
    notifyListeners();

    // final url = Uri.parse(constants.chatbotBaseUrl);
    /*    Map<String, dynamic> data = {
      "question": userMessage,
      "overrideConfig": {"sessionId": AppState.instance.sessionId},
    };*/

    Map<String, dynamic> data = {
      'input_value': userMessage,
      'output_type': 'chat',
      'input_type': 'chat'
      // 'session_id': AppState.instance.sessionId
    };

    Object postData = jsonEncode(data);

    String url = 'https://$domain/api/v1/run/$flowId';
    print("post data::$postData");
    try {
      final request = http.Request('POST', Uri.parse(url))
        // ..headers['Authorization'] = 'Bearer $bearerToken'
        ..headers['Content-Type'] = 'application/json'
        ..headers['x-api-key'] = apiKey
        ..body = jsonEncode(data);

      final streamedResponse = await request.send();
      final stream = streamedResponse.stream.transform(utf8.decoder);

      await for (var chunk in stream) {
        if (chunk.trim().isEmpty) continue;

        final data = jsonDecode(chunk);
        String messageText = data['outputs'][0]['outputs'][0]['results']
            ['message']['data']['text'];

        if (messageText.isNotEmpty) {
          messages.add({
            'text': messageText,
            'is_user': false,
          });
          showLoader.value = false;
          notifyListeners();
        }

        if (data['isStreamValid'] == false) {
          showLoader.value = false;
          notifyListeners();
          break;
        }
      }
    } catch (e) {
      showLoader.value = false;
      Fluttertoast.showToast(msg: "Something went wrong!");
      notifyListeners();
    }
  }

  void toggleExpandAllSteps() {
    showAllStepsExpanded.value = !showAllStepsExpanded.value;
  }

  Map<String, dynamic>? extractContentBlocks(List<Map<String, dynamic>> steps) {
    final Map<String, dynamic> data = {};

    for (final step in steps) {
      if (step.isNotEmpty) {
        final key = step.keys.first;
        final value = step.values.first;
        data[key] = value;
      }
    }

    return data.isNotEmpty ? data : null;
  }
}
