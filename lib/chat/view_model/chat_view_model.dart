import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat/model/chat_history_model.dart';
import 'package:gka/chat/model/chat_message_history.dart';
import 'package:gka/chat/model/get_documents_response.dart';
import 'package:gka/chat/model/get_users_response.dart';
import 'package:gka/chat/model/sse_event_model.dart';
import 'package:gka/chat/model/processing_step_model.dart';
import 'package:gka/chat/model/video_data_model.dart';
import 'package:gka/shared/loading_view_model.dart';
import 'package:gka/utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';

import '../../home/model/available_models.dart' as model;
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
  var scrollControllerListView = ScrollController();
  int prevChatLength = 0;

  int responseCount = 1;
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
  final player = AudioPlayer();
  bool speechToTextOn = false;
  bool isVoiceInitiated = false;
  int timerCounter = 0;
  int loaderCounter = 0;
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
  String userQuery = "";
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
  String imageUrl = '';

  File? capturedPhoto;

  Map<String, String> currentVoice = {
    "name": "en-us-x-iom-local",
    "locale": "en-US"
  };

  final SpeechToText _speechToText = SpeechToText();
  FlutterTts tts = FlutterTts();
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
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  ValueNotifier<bool> showAllStepsExpanded = ValueNotifier(false);
  ValueNotifier<bool> expandAllSteps = ValueNotifier(false);
  String tempStreamingText = '';
  bool isFetchingMore = false;
  bool hasMoreData = true;
  int oldMsgId = 0;

  // Streaming TTS state variables
  String streamingTtsBuffer = '';
  bool isStreamingTtsActive = false;
  int streamingTtsChunkCount = 0;
  DateTime? lastTtsChunkTime;

  int currentPage = 1;
  final int pageSize = 10;
  int start = 0;
  int end = 0;
  bool hasSpoken = false;
  int prevChatLengthHistory = 0;
  int c = 0;
  String highlightedText = "";
  String remainingText = "";
  bool isllmDropdown = false;
  List<Map<String, dynamic>> messages = [];
  String url = '';
  IOWebSocketChannel? channel;
  late ChatViewModel viewModel;

  List<String> langLoaderMsgList = [];
  List<String> llmOptionsList = ['chatgpt-4o', 'gemma2:9b', 'deepseek-r1'];
  List<String> langList = ['English', 'Telugu'];

  String langId = 'en-US';
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

  // New query-stream processing state
  List<ProcessingStepModel> processingSteps = [];
  Map<String, int> stepTimings = {};
  int? startTime;
  bool includeDetails = true;

  String? currentTtsMessage;

  // ValueNotifiers for the thinking container
  ValueNotifier<bool> isQueryProcessing = ValueNotifier<bool>(false);
  ValueNotifier<bool> showThinkingContainer = ValueNotifier<bool>(true);

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
    contentBlocksData.clear();
    currentSteps.clear();
    selectedFile = null;
    isUploading = false;
    agentSteps = [];
    debugSseEvents = [];
    isStreaming.value = false;
    showLoader.value = false;
    isQueryProcessing.value = false;
    showThinkingContainer.value = true;
    streamingText.value = "";
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
              getAllPromptsResponseModel.response!.isNotEmpty) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No file selected')));
      return false;
    } else {
      isUploading = true;
      bool? value = await uploadDocument(context, selectedFile!.path);
      isUploading = false;
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
        if (result) {
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
                "increased_limit": int.parse(text)
              }
            : params = {
                "user_id": AppState.instance.userId,
                "decreased_limit": int.parse(text)
              };
        ActivityStatusResponse activityStatusResponse =
            await repo.submitActivityStatus(params, isIncreased);
        if (activityStatusResponse.statusCode == 200) {
          return true;
        }
        return false;
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

  Future? getMessageHistoryForSession(String? sessionId, BuildContext context,
      {bool isLoadMore = false}) async {
    if (await networkUtils.hasActiveInternet()) {
      if (isFetchingMore || (!hasMoreData && isLoadMore)) return;

      if (isLoadMore) {
        isFetchingMore = true;
      } else {
        isLoading = true;
        hasMoreData = true;
        oldMsgId = 0;
        messages.clear();
      }
      notifyListeners();
      try {
        ChatHistoryModel chatHistoryModel = await repo
            .fetchChatHistoryForSession(sessionId!, context, oldMsgId);
        chatHistoryModel.data.sort((a, b) =>
            DateTime.parse(a.createdAt).compareTo(DateTime.parse(b.createdAt)));
        if (chatHistoryModel.data.isNotEmpty) {
          int leastMessageId = chatHistoryModel.data
              .map((msg) => msg.messageId)
              .reduce((a, b) => a < b ? a : b);

          print('Least messageId: $leastMessageId');
          oldMsgId = leastMessageId;
          for (ChatMessageHistoryModel item in chatHistoryModel.data) {
            messages.add({
              'text': item.text,
              'is_user': item.senderType.toLowerCase() == "user" ? true : false,
            });
          }
          isLoading = false;
          notifyListeners();
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

  Future<void> getSessionsForUser(BuildContext context,
      {bool isLoadMore = false}) async {
    if (await networkUtils.hasActiveInternet()) {
      if (isFetchingMore || (!hasMoreData && isLoadMore)) return;

      if (isLoadMore) {
        isFetchingMore = true;
      } else {
        isLoading = true;
        currentPage = 1;
        hasMoreData = true;
        sessionIdDataMapping.clear();
      }

      notifyListeners();

      try {
        // Call paginated API with current page and size
        UserSessionModel userSessionModel =
            await repo.fetchUserSessions(currentPage, pageSize);

        if (userSessionModel.data.isNotEmpty) {
          userSessionModel.data.sort((a, b) =>
              DateTime.parse(b.insertTs).compareTo(DateTime.parse(a.insertTs)));

          for (var item in userSessionModel.data) {
            sessionIdDataMapping[item.sessionId] = item.insertTs;
          }

          currentPage++;
          if (userSessionModel.data.length < pageSize) {
            hasMoreData = false;
          }
        } else {
          hasMoreData = false;
        }
        debugPrint(
            "sessionIdDataMapping length - ${sessionIdDataMapping.length}");
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance.logMessage('Chat View Model', 'Error $e');
      }

      isLoading = false;
      isFetchingMore = false;
      notifyListeners();
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
        if (chatMessageHistoryList.isNotEmpty) {
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

  Future<void> initDeviceId() async {
    String deviceId = const Uuid().v4();

    url = 'wss://apaims2.0.vassarlabs.com/chatbot/ws/chat/$deviceId';
    print("12345 Generated Device ID: $deviceId");
    print("12345 Web socket URL: $url");
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

  void updateChatControllerForSpeech(String text) {
    chatController.clear();
    chatController.text = text;
    notifyListeners();
  }

  sendAudioToAPI(String path, BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      updateChatControllerForSpeech('Processing...');
      try {
        final bytes = await File(path).readAsBytes();
        final base64Audio = base64Encode(bytes);
        String sourceLanguage = AppState.instance.isEnglish ? 'en' : 'te';
        String serviceId = AppState.instance.isEnglish
            ? constants.asrServiceIdEnglish
            : constants.asrServiceIdTelugu;

        final body = {
          "pipelineTasks": [
            {
              "taskType": "asr",
              "config": {
                "language": {"sourceLanguage": sourceLanguage},
                "serviceId": serviceId,
                "audioFormat": "flac",
                "samplingRate": 16000
              }
            }
          ],
          "inputData": {
            "audio": [
              {"audioContent": base64Audio}
            ]
          }
        };
        final pipelineResponse = await repo.fetchASRconfig(body);
        if (pipelineResponse.isNotEmpty) {
          final asrTask = pipelineResponse.firstWhere(
              (task) => task['taskType'] == 'asr',
              orElse: () => null);

          final sourceText = asrTask?['output']?[0]?['source'];

          sourceText != null ? updateChatControllerForSpeech(sourceText) : null;
        } else {
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

  resembleAItts(String ttsText, BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      try {
        String plainText = _extractPlainText(ttsText.trim());
        final body = {"text": plainText};
        String? base64Audio = await repo.fetchResembleAItts(body);

        if (base64Audio != null && base64Audio.isNotEmpty) {
          Uint8List audioBytes = base64Decode(base64Audio);
          await player.play(BytesSource(audioBytes));
        } else {
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

  Future<void> ttsResponse(String ttsText, BuildContext context) async {
    String targetLanguage = AppState.instance.isEnglish ? 'en' : 'te';
    String plainText = _extractPlainText(ttsText.trim());

    if (await networkUtils.hasActiveInternet()) {
      try {
        final body = {
          "pipelineTasks": [
            {
              "taskType": "tts",
              "config": {
                "language": {"sourceLanguage": targetLanguage},
                "serviceId": constants.ttsServiceId,
                "gender": "female",
                "samplingRate": 8000
              }
            }
          ],
          "inputData": {
            "input": [
              {"source": plainText}
            ]
          }
        };

        final pipelineResponse = await repo.fetchTTSconfig(body);

        if (pipelineResponse.isNotEmpty) {
          final ttsTask = pipelineResponse.firstWhere(
            (task) => task['taskType'] == 'tts',
            orElse: () => null,
          );
          final List<dynamic>? audioList = ttsTask?['audio'];
          final String? base64Audio = audioList != null &&
                  audioList.isNotEmpty &&
                  audioList[0]['audioContent'] != null
              ? audioList[0]['audioContent'].toString()
              : null;

          if (base64Audio != null) {
            Uint8List audioBytes = base64Decode(base64Audio);

            ///stop any current audio before playing new
            await player.stop();

            /// Use Completer to await completion
            final completer = Completer<void>();

            StreamSubscription? subscription;

            subscription = player.onPlayerComplete.listen((event) {
              if (!completer.isCompleted) {
                completer.complete();
              }
              subscription?.cancel();
            });

            await player.play(BytesSource(audioBytes));

            //  Wait until audio finishes
            await completer.future;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(constants.genericErrorMsg),
            ));
          }
        } else {
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

  setlangCodes() {
    langId = AppState.instance.isEnglish ? 'en-US' : 'te-IN';
    currentVoice = AppState.instance.isEnglish
        ? currentVoice = {"name": "en-us-x-iom-local", "locale": "en-US"}
        : currentVoice = {"name": "te-in-x-tef-local", "locale": "te-IN"};
    notifyListeners();
  }

  sendAudioForTranscription(
      String recordedFilePath, BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      try {
        updateChatControllerForSpeech('Processing...');
        File audioFile = File(recordedFilePath);
        String? text = await repo.parakeetTranscription(audioFile);
        if (text != null && text.isNotEmpty) {
          updateChatControllerForSpeech(text);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(constants.genericErrorMsg)));
        }
      } catch (e) {
        print("WebSocket error: $e");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(constants.genericErrorMsg)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(constants.noNetworkAvailability)));
    }
  }

  /// Send message using the new query-stream API with SSE
  Future<void> sendMessageWithQueryStream(
      String? sessionId, BuildContext context) async {
    userQuery = chatController.text;

    // Add user message to chat
    messages.add({
      'text': userQuery,
      'is_user': true,
      'image_url': imageUrl,
      'timestamp': DateTime.now().toIso8601String(),
    });

    capturedPhoto = null;
    chatController.clear();
    isQueryProcessing.value = true;
    showLoader.value = false;
    processingSteps.clear();
    stepTimings.clear();
    startTime = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();

    // Start query processing with SSE
    await _startQueryProcessing(sessionId!, context);
  }

  /// Start the query processing with SSE stream
  Future<void> _startQueryProcessing(
      String sessionId, BuildContext context) async {
    // Create initial API connection step
    _updateProcessingStep(
      'api_connection',
      'API Connection',
      StepStatus.inProgress,
      'Connecting to API...',
    );

    final requestBody = {
      'query': userQuery,
      'session_id': sessionId,
      'user_id': AppState.instance.userId,
      'language': AppState.instance.isEnglish ? 'en' : 'te',
      'retrieval_type': AppState.instance.vassarDigitalRetrievalEnabled
          ? 'vassar_digital_retrieval'
          : 'native',
      'include_details': includeDetails,
      'image_url': imageUrl
    };

    if (!AppState.instance.isEnglish) {
      String translatorEngine = '';
      if (AppState.instance.transMode == 'Bhashini') {
        translatorEngine = 'bhashini';
      }
      if (AppState.instance.transMode == 'Google Translate') {
        translatorEngine = 'google';
      }
      if (AppState.instance.transMode == 'LLM Translate') {
        translatorEngine = 'llm_translate';
      }
      requestBody['translation_engine'] = translatorEngine;
    }

    debugPrint("Query Stream request body : $requestBody");

    String apiUrl = constants.baseUrl + constants.queryStreamEndpoint;

    try {
      final client = http.Client();
      final request = http.Request('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      });
      request.body = jsonEncode(requestBody);

      final streamedResponse = await client.send(request);

      if (streamedResponse.statusCode != 200) {
        _updateProcessingStep(
          'api_connection',
          'API Connection',
          StepStatus.error,
          'API request failed: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}',
        );
        _completeProcessing(false, context);
        client.close();
        return;
      }

      _updateProcessingStep(
        'api_connection',
        'API Connection',
        StepStatus.completed,
        'Connected. Streaming events...',
      );

      // Process SSE stream
      await _processSSEStreamFromResponse(streamedResponse, context);
      client.close();
    } catch (e) {
      print('Query stream error: $e');
      _updateProcessingStep(
        'api_connection',
        'API Connection',
        StepStatus.error,
        'Connection error: $e',
      );
      _completeProcessing(false, context);
    }
  }

  /// Process the SSE stream from a StreamedResponse
  Future<void> _processSSEStreamFromResponse(
      http.StreamedResponse response, BuildContext context) async {
    String buffer = '';

    await for (final chunk in response.stream.transform(utf8.decoder)) {
      buffer += chunk;

      // Process complete lines
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // Keep incomplete line in buffer

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        if (trimmed.startsWith('data: ')) {
          try {
            final sseDataString = trimmed.substring(6).trim();
            if (sseDataString.isNotEmpty && sseDataString != '[DONE]') {
              final eventData = jsonDecode(sseDataString);
              final sseEvent = SSEEventModel.fromJson(eventData);

              await _handleSSEEvent(sseEvent, context);

              if (sseEvent.step == 'complete') {
                _completeProcessing(true, context, sseEvent.finalAnswer);
                return;
              }
            }
          } catch (e) {
            print('Error parsing SSE event: $e');
            print('Problematic line: $trimmed');
            _updateProcessingStep(
              'parsing_error',
              'Parsing Error',
              StepStatus.error,
              'Error parsing stream data: $e',
            );
          }
        }
      }
    }

    // Process any remaining buffer content
    if (buffer.trim().isNotEmpty && buffer.trim().startsWith('data: ')) {
      try {
        final sseDataString = buffer.trim().substring(6).trim();
        if (sseDataString.isNotEmpty && sseDataString != '[DONE]') {
          final eventData = jsonDecode(sseDataString);
          final sseEvent = SSEEventModel.fromJson(eventData);
          await _handleSSEEvent(sseEvent, context);

          if (sseEvent.step == 'complete') {
            _completeProcessing(true, context, sseEvent.finalAnswer);
            return;
          }
        }
      } catch (e) {
        print('Error parsing final SSE event: $e');
      }
    }

    // If we reach here without completing, something went wrong
    if (isQueryProcessing.value) {
      _completeProcessing(false, context);
    }
  }

  /// Handle individual SSE events
  Future<void> _handleSSEEvent(
      SSEEventModel event, BuildContext context) async {
    print('SSE Event: ${event.step} - ${event.status} - ${event.message}');

    // Track step timing
    final stepStartKey = '${event.step}_start';
    if (event.status == 'in_progress' &&
        !stepTimings.containsKey(stepStartKey)) {
      stepTimings[stepStartKey] = DateTime.now().millisecondsSinceEpoch;
    }

    int? duration;
    if (event.status == 'completed' ||
        event.status == 'skipped' ||
        event.status == 'error') {
      final stepStart = stepTimings[stepStartKey];
      if (stepStart != null) {
        duration = DateTime.now().millisecondsSinceEpoch - stepStart;
        stepTimings['${event.step}_final_duration'] = duration;
      }
    }

    // Handle streaming TTS for various event types
    await _processEventForStreamingTTS(event, context);

    // Update step status
    _updateProcessingStep(
      event.step,
      ProcessingStepModel.formatStepName(event.step),
      _mapStringToStepStatus(event.status),
      event.message,
      duration: duration,
      details: _formatEventDetails(event),
    );

    notifyListeners();
  }

  /// Process SSE events for streaming TTS
  Future<void> _processEventForStreamingTTS(
      SSEEventModel event, BuildContext context) async {
    if (!AppState.instance.autoSpeechEnabled) return;

    print(
        '[STREAMING TTS] Processing SSE event - Step: ${event.step}, Status: ${event.status}');

    // Initialize streaming TTS on answer generation start
    if (event.step == 'answer_generation' && event.status == 'in_progress') {
      print('[STREAMING TTS] Starting streaming TTS for answer generation');
      isStreamingTtsActive = true;
      resetStreamingTTS();
    }

    // Process streaming text content from various event sources
    String? streamingText;

    switch (event.step) {
      case 'answer_generation':
        if (event.status == 'in_progress' && event.message.isNotEmpty) {
          streamingText = event.message;
          print('[STREAMING TTS] Answer generation message: "$streamingText"');
        } else if (event.llmPrompt != null && event.llmPrompt!.isNotEmpty) {
          streamingText = event.llmPrompt;
          print('[STREAMING TTS] LLM prompt content: "$streamingText"');
        }
        break;

      case 'translation':
        if (event.translatedQuery != null &&
            event.translatedQuery!.isNotEmpty) {
          streamingText = event.translatedQuery;
          print('[STREAMING TTS] Translated query: "$streamingText"');
        }
        break;

      case 'restructure_route':
        if (event.restructuredQuestion != null &&
            event.restructuredQuestion!.isNotEmpty) {
          streamingText = event.restructuredQuestion;
          print('[STREAMING TTS] Restructured question: "$streamingText"');
        }
        break;

      case 'complete':
        if (event.finalAnswer != null && event.finalAnswer!.isNotEmpty) {
          print(
              '[STREAMING TTS] Final answer received - completing streaming TTS');
          // Process any remaining content and mark as complete
          streamingText = event.finalAnswer;
        }
        break;
    }

    /*// Trigger streaming TTS if we have content
    if (streamingText != null &&
        streamingText.isNotEmpty &&
        isStreamingTtsActive) {
      await handleStreamingTTS(streamingText, context);
    }*/

    // Mark streaming TTS as inactive after processing final answer
    if (event.step == 'complete' &&
        event.finalAnswer != null &&
        event.finalAnswer!.isNotEmpty) {
      isStreamingTtsActive = false;
    }
  }

  /// Update or create a processing step
  void _updateProcessingStep(
    String stepName,
    String displayName,
    StepStatus status,
    dynamic message, {
    int? duration,
    Map<String, dynamic>? details,
  }) {
    final existingIndex =
        processingSteps.indexWhere((step) => step.name == stepName);

    if (existingIndex != -1) {
      // Update existing step
      processingSteps[existingIndex] = processingSteps[existingIndex].copyWith(
        status: status,
        message: message,
        duration: duration,
        details: details,
      );
    } else {
      // Create new step
      processingSteps.add(ProcessingStepModel(
        name: stepName,
        displayName: displayName,
        status: status,
        message: message,
        startTime: stepTimings['${stepName}_start'],
        duration: duration,
        details: details,
      ));
    }

    notifyListeners();
  }

  String? extractImageUrl(String text) {
    final regex =
        RegExp(r'https:\/\/minio\.apaims2\.0\.vassarlabs\.com\/[^\s]+\.jpeg');
    final match = regex.firstMatch(text);
    return match?.group(0); // Returns the first match or null
  }

  /// Complete the processing workflow
  Future<void> _completeProcessing(bool success, BuildContext context,
      [String? finalAnswer]) async {
    isQueryProcessing.value = false;
    showLoader.value = false;

    if (success && finalAnswer != null) {
      String? imageUrl = extractImageUrl(finalAnswer);

      finalAnswer = finalAnswer.replaceAll(
          RegExp(
              r'^.*https:\/\/minio\.apaims2\.0\.vassarlabs\.com\/[^\s]+\.jpeg.*$',
              multiLine: true),
          '');
      finalAnswer =
          finalAnswer.replaceAll(RegExp(r'\n\s*\n+', multiLine: true), '\n\n');

      // Add assistant response to messages
      messages.add({
        'text': finalAnswer.trim(),
        'is_user': false,
        'image_url': imageUrl,
        'timestamp': DateTime.now().toIso8601String(),
        'processing_steps':
            processingSteps.map((step) => step.toJson()).toList(),
      });

      // Trigger auto speech for AI response
      await handleTTSResponse(finalAnswer.trim(), context);
    } else if (!success) {
      messages.add({
        'text':
            'Sorry, an error occurred while processing your request. Please try again.',
        'is_user': false,
        'timestamp': DateTime.now().toIso8601String(),
        'processing_steps':
            processingSteps.map((step) => step.toJson()).toList(),
      });
    }
    notifyListeners();
  }

  /// Handle TTS response
  Future<void> handleTTSResponse(String response, BuildContext context) async {
    // Check if auto speech is enabled
    if (!AppState.instance.autoSpeechEnabled) return;

    bool hasEnglishSource = RegExp(r'\(Source:.*?\)').hasMatch(response);
    bool hasTeluguSource = RegExp(r'\(మూలం:.*?\)').hasMatch(response);
    String noSourceText = '';

    /* if (hasEnglishSource) {
      noSourceText = response.replaceAll(RegExp(r'\s*\(Source:.*?\)'), '');
    } else if (hasTeluguSource) {
      noSourceText = response.replaceAll(RegExp(r'\s*\(మూలం:.*?\)'), '');
    } else {
      noSourceText = response;
    }*/

    final ttsText = sanitizeTextForTTS(noSourceText);

    if (noSourceText.toString().isNotEmpty && response.toString().isNotEmpty) {
      // Use processing mode based on user setting
      if (AppState.instance.ttsChunkedMode) {
        // Use chunk-wise TTS processing
        await handleChunkwiseTTS(ttsText, context);
      } else {
        // Use full text TTS processing
        await handleFullTextTTS(ttsText, context);
      }
    }
  }

  /// Handle chunk-wise TTS processing
  Future<void> handleChunkwiseTTS(String text, BuildContext context) async {
    final chunks = _splitIntoChunks(text, wordsPerChunk: 10);

    print('[CHUNKWISE TTS] Split into ${chunks.length} chunks:');
    final audioChunks = await fetchAllAudioChunks(chunks, context);
    await playAudioChunksSequentially(audioChunks);
  }

  Future<List<Uint8List>> fetchAllAudioChunks(
      List<String> chunks, BuildContext context) async {
    List<Uint8List> audioChunks = [];

    for (String chunk in chunks) {
      if (!AppState.instance.autoSpeechEnabled) break;

      String targetLanguage = AppState.instance.isEnglish ? 'en' : 'te';
      String plainText = _extractPlainText(chunk.trim());

      final body = {
        "pipelineTasks": [
          {
            "taskType": "tts",
            "config": {
              "language": {"sourceLanguage": targetLanguage},
              "serviceId": constants.ttsServiceId,
              "gender": "female",
              "samplingRate": 8000
            }
          }
        ],
        "inputData": {
          "input": [
            {"source": plainText}
          ]
        }
      };

      final pipelineResponse = await repo.fetchTTSconfig(body);

      if (pipelineResponse.isNotEmpty) {
        final ttsTask = pipelineResponse.firstWhere(
          (task) => task['taskType'] == 'tts',
          orElse: () => null,
        );
        final List<dynamic>? audioList = ttsTask?['audio'];
        final String? base64Audio = audioList != null &&
                audioList.isNotEmpty &&
                audioList[0]['audioContent'] != null
            ? audioList[0]['audioContent'].toString()
            : null;

        if (base64Audio != null) {
          Uint8List audioBytes = base64Decode(base64Audio);
          audioChunks.add(audioBytes);
        }
      }
    }

    return audioChunks;
  }

  /// Handle full text TTS processing (no chunking)
  Future<void> handleFullTextTTS(String text, BuildContext context) async {
    print(
        '[FULL TEXT TTS] Processing entire text: "${text.substring(0, text.length.clamp(0, 100))}${text.length > 100 ? '...' : ''}"');

    if (AppState.instance.ttsMode.toLowerCase() == 'bhashini') {
      await ttsResponse(text, context);
    } else if (AppState.instance.ttsMode.toLowerCase() == 'native') {
      await nativeTTS(text);
    } else if (AppState.instance.ttsMode.toLowerCase() == 'resemble ai') {
      await resembleAItts(text, context);
    }
  }

  /// Handle streaming text chunks for real-time TTS processing
  Future<void> handleStreamingTTS(
      String incomingText, BuildContext context) async {
    if (!AppState.instance.autoSpeechEnabled) return;

    final currentTime = DateTime.now();
    print(
        '[STREAMING TTS] Processing incoming text: "${incomingText.length > 50 ? incomingText.substring(0, 50) + "..." : incomingText}"');

    // Add incoming text to buffer
    streamingTtsBuffer += incomingText;
    lastTtsChunkTime = currentTime;

    // Clean the buffer text for TTS
    String cleanedBuffer = sanitizeTextForTTS(streamingTtsBuffer);

    // Check user's TTS processing mode preference
    if (AppState.instance.ttsChunkedMode) {
      // Chunked processing mode - split buffer into sentences for natural TTS chunks
      List<String> sentences = cleanedBuffer.split(RegExp(r'(?<=[.!?])\s+'));

      // Process complete sentences for TTS
      if (sentences.length > 1) {
        // Keep the last incomplete sentence in buffer
        String lastSentence = sentences.removeLast();

        for (String sentence in sentences) {
          if (sentence.trim().isNotEmpty &&
              AppState.instance.autoSpeechEnabled) {
            streamingTtsChunkCount++;
            print(
                '[STREAMING TTS CHUNKED] Speaking chunk #${streamingTtsChunkCount}: "${sentence.trim()}"');

            await _speakStreamingChunk(sentence.trim(), context);

            // Small delay between streaming chunks
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }

        // Update buffer with remaining incomplete sentence
        streamingTtsBuffer = lastSentence;
      }
    } else {
      // Full text mode - wait for complete response, don't process streaming chunks
      print(
          '[STREAMING TTS FULL] Accumulating text, will process when complete. Buffer length: ${cleanedBuffer.length}');
      // In full text mode, we don't process streaming chunks
      // The complete response will be handled by handleFinalResponseTTS
    }

    // Handle timeout for remaining buffer content (only in chunked mode)
    if (AppState.instance.ttsChunkedMode) {
      Future.delayed(const Duration(seconds: 2), () async {
        if (lastTtsChunkTime == currentTime &&
            streamingTtsBuffer.trim().isNotEmpty &&
            AppState.instance.autoSpeechEnabled) {
          print(
              '[STREAMING TTS CHUNKED] Processing remaining buffer on timeout: "${streamingTtsBuffer.trim()}"');
          streamingTtsChunkCount++;
          await _speakStreamingChunk(streamingTtsBuffer.trim(), context);
          streamingTtsBuffer = '';
        }
      });
    }
  }

  /// Speak a single streaming chunk using the configured TTS provider
  Future<void> _speakStreamingChunk(String text, BuildContext context) async {
    try {
      print(
          '[STREAMING TTS] TTS Provider: ${AppState.instance.ttsMode}, Text: "$text"');

      // Apply proper chunking if in chunked mode
      if (AppState.instance.ttsChunkedMode) {
        // Split the sentence into optimal chunks
        List<String> chunks = _splitResponseIntoTTSChunks(text);
        print('[STREAMING TTS] Split sentence into ${chunks.length} chunks');

        for (String chunk in chunks) {
          if (!AppState.instance.autoSpeechEnabled) break;

          print('[STREAMING TTS CHUNK] Speaking: "$chunk"');

          if (AppState.instance.ttsMode.toLowerCase() == 'bhashini') {
            await ttsResponse(chunk, context);
          } else if (AppState.instance.ttsMode.toLowerCase() == 'native') {
            await nativeTTS(chunk);
          } else if (AppState.instance.ttsMode.toLowerCase() == 'resemble ai') {
            await resembleAItts(chunk, context);
          }

          // Small delay between chunks
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } else {
        // Full text mode - process entire sentence at once
        if (AppState.instance.ttsMode.toLowerCase() == 'bhashini') {
          await ttsResponse(text, context);
        } else if (AppState.instance.ttsMode.toLowerCase() == 'native') {
          await nativeTTS(text);
        } else if (AppState.instance.ttsMode.toLowerCase() == 'resemble ai') {
          await resembleAItts(text, context);
        }
      }

      print('[STREAMING TTS] Successfully spoke text: "$text"');
    } catch (e) {
      print('[STREAMING TTS ERROR] Failed to speak text "$text": $e');
    }
  }

  /// Reset streaming TTS state
  void resetStreamingTTS() {
    print('[STREAMING TTS] Resetting streaming TTS state');
    streamingTtsBuffer = '';
    isStreamingTtsActive = false;
    streamingTtsChunkCount = 0;
    lastTtsChunkTime = null;
  }

  String _extractPlainText(String text) {
    // Remove double asterisks for bold text
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    String result =
        text.replaceAllMapped(boldRegex, (match) => match.group(1) ?? '');

    // Remove single asterisks
    final RegExp singleAsteriskRegex = RegExp(r'\*');
    result = result.replaceAll(singleAsteriskRegex, '');

    // Remove newlines
    result = result.replaceAll('\\n', ' ');
    print("result ::$result");
    return result.trim();
  }

  /// Format event details for display
  Map<String, dynamic>? _formatEventDetails(SSEEventModel event) {
    if (!includeDetails) return null;

    final details = <String, dynamic>{};

    // Add step-specific details
    switch (event.step) {
      case 'translation':
        if (event.translatedQuery != null) {
          details['translated_query'] = event.translatedQuery;
        }
        if (event.sourceLang != null && event.targetLang != null) {
          details['language'] = '${event.sourceLang} → ${event.targetLang}';
        }
        break;

      case 'restructure_route':
      case 'workflow_init':
        if (event.collection != null) {
          details['collection'] = event.collection;
        }
        if (event.isSmallTalk != null) {
          details['is_small_talk'] = event.isSmallTalk;
        }
        if (event.routingConfidence != null) {
          details['routing_confidence'] =
              '${(event.routingConfidence! * 100).toStringAsFixed(1)}%';
        }
        if (event.restructuredQuestion != null) {
          details['restructured_question'] = event.restructuredQuestion;
        }
        break;

      case 'retrieval':
        if (event.chunksCount != null) {
          details['chunks_retrieved'] = event.chunksCount;
        }
        if (event.retrievalType != null) {
          details['retrieval_type'] = event.retrievalType;
        }
        if (event.top10Chunks != null) {
          details['top_10_chunks'] = event.top10Chunks;
        }
        break;

      case 'answer_generation':
        if (event.modelUsed != null) {
          details['model_used'] = event.modelUsed;
        }
        if (event.tokensGenerated != null) {
          details['tokens_generated'] = event.tokensGenerated;
        }
        if (event.llmPrompt != null) {
          details['llm_prompt'] = event.llmPrompt!;
        }
        break;

      case 'date_extraction':
        if (event.data != null) {
          details['date_extraction'] = event.data;
        }
        break;

      case 'location_extraction':
        if (event.data != null) {
          details['location_extraction'] = event.data;
        }
        break;

      case 'location_search':
        if (event.data != null) {
          details['location_search'] = event.data;
        }
        break;

      case 'weather_api_params':
        if (event.data != null) {
          details['weather_api_params'] = event.data;
        }
        break;

      case 'weather_components_init':
        if (event.data != null) {
          details['weather_components_init'] = event.data;
        }
        break;

      case 'weather_api_rainfall_request':
        if (event.data != null) {
          details['weather_api_rainfall_request'] = event.data;
        }
        break;

      case 'weather_api_rainfall_response':
        if (event.data != null) {
          details['weather_api_rainfall_response'] = event.data;
        }
        break;

      case 'weather_api_rainfall_success':
        if (event.data != null) {
          details['weather_api_rainfall_success'] = event.data;
        }
        break;

      case 'weather_api_temperature_request':
        if (event.data != null) {
          details['weather_api_temperature_request'] = event.data;
        }
        break;

      case 'weather_api_temperature_response':
        if (event.data != null) {
          details['weather_api_temperature_response'] = event.data;
        }
        break;

      case 'weather_api_temperature_success':
        if (event.data != null) {
          details['weather_api_temperature_success'] = event.data;
        }
        break;

      case 'weather_api_humidity_request':
        if (event.data != null) {
          details['weather_api_humidity_request'] = event.data;
        }
        break;

      case 'weather_api_humidity_response':
        if (event.data != null) {
          details['weather_api_humidity_response'] = event.data;
        }
        break;

      case 'weather_api_humidity_success':
        if (event.data != null) {
          details['weather_api_humidity_success'] = event.data;
        }
        break;

      case 'weather_api_wind_request':
        if (event.data != null) {
          details['weather_api_wind_request'] = event.data;
        }
        break;

      case 'weather_api_wind_response':
        if (event.data != null) {
          details['weather_api_wind_response'] = event.data;
        }
        break;

      case 'weather_api_wind_success':
        if (event.data != null) {
          details['weather_api_wind_success'] = event.data;
        }
        break;

      case 'vision_processing':
        if (event.imagesProcessed != null) {
          details['images_processed'] = event.imagesProcessed;
        }
        if (event.visionModel != null) {
          details['vision_model'] = event.visionModel;
        }
        break;

      case 'web_search':
        if (event.searchQuery != null) {
          details['search_query'] = event.searchQuery;
        }
        if (event.resultsCount != null) {
          details['results_count'] = event.resultsCount;
        }
        break;

      case 'citation':
        print("citation event message : ${event.message}");
        if (event.message != null) {
          try {
            final message = event.message;

            final videoMetadata = message['video_metadata'] as List<dynamic>?;

            if (videoMetadata != null && videoMetadata.isNotEmpty) {
              const baseUrl =
                  'https://minio.apaims2.0.vassarlabs.com/genai/cms/';

              final Set<String> uniqueKeys = {};
              List<VideoDataModel> videoDataList = [];

              for (final item in videoMetadata) {
                if (item is Map<String, dynamic>) {
                  final source = item['source'];
                  final start = item['start'];
                  final end = item['end'];

                  if (source != null &&
                      source.toString().toLowerCase().endsWith('.mp4')) {
                    final key = '$source|$start|$end';
                    if (!uniqueKeys.contains(key)) {
                      uniqueKeys.add(key);
                      final encodedSource =
                          Uri.encodeComponent(source.toString());
                      final videoUrl = '$baseUrl$encodedSource';
                      videoDataList.add(VideoDataModel(videoUrl, start, end));
                    }
                  }
                }
              }

              details['video_data'] = videoDataList;
            }
          } catch (e) {
            Fluttertoast.showToast(msg: 'Failed to decode citation message $e');
          }
        }
        break;
    }

    // Add error details
    if (event.error != null) {
      details['error'] = event.error.toString();
    }
    print("details : ${details}");

    return details.isNotEmpty ? details : null;
  }

  /// Map string status to StepStatus enum
  StepStatus _mapStringToStepStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return StepStatus.pending;
      case 'in_progress':
        return StepStatus.inProgress;
      case 'completed':
        return StepStatus.completed;
      case 'error':
        return StepStatus.error;
      case 'skipped':
        return StepStatus.skipped;
      default:
        return StepStatus.pending;
    }
  }

  /// Generate a unique session ID
  String generateSessionId() {
    return const Uuid().v4();
  }

  /// Get total processing duration
  int get totalProcessingDuration {
    return processingSteps
        .where((step) => step.duration != null)
        .fold(0, (sum, step) => sum + step.duration!);
  }

  /// Toggle thinking container visibility
  void toggleThinkingContainer() {
    showThinkingContainer.value = !showThinkingContainer.value;
    notifyListeners();
  }

  /// Toggle include details option
  void toggleIncludeDetails() {
    includeDetails = !includeDetails;
    notifyListeners();
  }

  /// Clear processing state
  void clearProcessingState() {
    processingSteps.clear();
    stepTimings.clear();
    isQueryProcessing.value = false;
    showThinkingContainer.value = true;
    startTime = null;
    notifyListeners();
  }

  uploadMediaToS3() async {
    imageUrl = '';
    try {
      String? value = await AwsS3.uploadFile(
        accessKey: constants.accessKey,
        secretKey: constants.secretKey,
        file: File(capturedPhoto!.path),
        bucket: constants.bucket,
        region: constants.region,
        destDir: constants.s3Filefolder,
      );
      if (value != null) {
        imageUrl = value;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: constants.genericErrorMsg);
    }
    debugPrint("IMAGE URL : $imageUrl");
  }

  saveCapturedPhoto(XFile photo) {
    capturedPhoto = File(photo.path);
    notifyListeners();
  }

  nativeTTS(String ttsText) async {
    /* isQueryProcessing.value = false;
    showLoader.value = false;
    notifyListeners();
    messages.add({
      'text': messageText.toString(),
      'is_user': false,
      'timestamp': DateTime.now().toIso8601String(),
      'processing_steps': processingSteps.map((step) => step.toJson()).toList(),
    });*/
    String plainText = _extractPlainText(ttsText.trim());
    await tts.setLanguage(langId);
    await tts.setVoice(currentVoice);
    await tts.setSpeechRate(0.5);
    await tts.speak(plainText);
  }

/*
  String removeIconsForTts(String input) {
    // Removes emojis and symbols
    return input
        .replaceAll(
          RegExp(
              r'[\u{1F600}-\u{1F64F}' // Emoticons
              r'\u{1F300}-\u{1F5FF}' // Misc Symbols and Pictographs
              r'\u{1F680}-\u{1F6FF}' // Transport and Map Symbols
              r'\u{2600}-\u{26FF}' // Misc symbols
              r'\u{2700}-\u{27BF}' // Dingbats
              r'\u{FE00}-\u{FE0F}' // Variation Selectors
              r'\u{1F900}-\u{1F9FF}' // Supplemental Symbols and Pictographs
              r'\u{1FA70}-\u{1FAFF}' // Symbols and Pictographs Extended-A
              r'\u{200D}' // Zero Width Joiner
              r']+',
              unicode: true),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim(); // Clean extra spaces
  }
*/

  String sanitizeTextForTTS(String input) {
    // Step 1: Remove emojis and symbols
    input = input.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}' // Emoticons
        r'\u{1F300}-\u{1F5FF}' // Misc Symbols and Pictographs
        r'\u{1F680}-\u{1F6FF}' // Transport and Map Symbols
        r'\u{2600}-\u{26FF}' // Misc symbols
        r'\u{2700}-\u{27BF}' // Dingbats
        r'\u{FE00}-\u{FE0F}' // Variation Selectors
        r'\u{1F900}-\u{1F9FF}' // Supplemental Symbols and Pictographs
        r'\u{1FA70}-\u{1FAFF}' // Symbols and Pictographs Extended-A
        r'\u{200D}' // Zero Width Joiner
        r']+',
        unicode: true,
      ),
      '',
    );

    // Step 2: Remove English and Telugu source tags
    input = input
        .replaceAll(RegExp(r'\s*\(Source:.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*\(మూలం:.*?\)'), '');

    // Step 3: Remove *, **, !, and bullets
    input = input
        .replaceAll(RegExp(r'\*+'), '') // Remove * or **
        .replaceAll('•', '') // Remove bullets
        .replaceAll(RegExp(r'!+'), '') // Remove multiple exclamations
        .replaceAll(RegExp(r'-+'), ' '); // Replace dashes with space

    // Step 4: Replace abbreviations with full forms
    input = input
        .replaceAllMapped(
            RegExp(r'\bmm\b', caseSensitive: false), (_) => 'millimeters')
        .replaceAllMapped(RegExp(r'°C\b'), (_) => 'Celsius')
        .replaceAllMapped(
            RegExp(r'\bHa\b', caseSensitive: false), (_) => 'hectares')
        .replaceAllMapped(
            RegExp(r'\bHect\b', caseSensitive: false), (_) => 'hectares')
        .replaceAllMapped(
            RegExp(r'\bQtl\b', caseSensitive: false), (_) => 'quintal')
        .replaceAllMapped(
            RegExp(r'\b(Rs|INR)\b', caseSensitive: false), (_) => 'rupees')
        .replaceAllMapped(RegExp(r'\bm/s\b', caseSensitive: false),
            (_) => 'meter per second');

    // Step 5: Clean up extra spaces
    input = input.replaceAll(RegExp(r'\s{2,}'), ' ').trim();

    return input;
  }

  Future<void> stopSpeaking() async {
    print('[STREAMING TTS] Stop speaking called - resetting all TTS state');

    // Disable auto speech to stop chunk processing
    AppState.instance.autoSpeechEnabled = false;

    // Reset streaming TTS state
    resetStreamingTTS();

    tts.stop();
    debugPrint("player.state :${player.state}");
    await player.stop();
    if (player.state == PlayerState.playing) {
      await player.stop();
      await player.release();
    }
    notifyListeners();
  }

  List<String> _splitIntoChunks(String text, {int wordsPerChunk = 10}) {
    List<String> words = text.trim().split(RegExp(r'\s+'));
    List<String> chunks = [];

    for (int i = 0; i < words.length; i += wordsPerChunk) {
      int end =
          (i + wordsPerChunk < words.length) ? i + wordsPerChunk : words.length;
      String chunk = words.sublist(i, end).join(' ');
      chunks.add(chunk);
    }

    return chunks;
  }

  /// Handle complete final response - process based on user's TTS mode preference
  Future<void> handleFinalResponseTTS(
      String completeResponse, BuildContext context) async {
    if (!AppState.instance.autoSpeechEnabled || completeResponse.trim().isEmpty)
      return;

    // Clean the complete response text for TTS
    String cleanedText = sanitizeTextForTTS(completeResponse);

    // Count words in complete response
    List<String> words = cleanedText.trim().split(RegExp(r'\s+'));

    // Only process if we have more than 5 words
    if (words.length > 5) {
      if (AppState.instance.ttsChunkedMode) {
        // Chunked processing mode
        print(
            '[CHUNKED TTS] Received complete response: ${completeResponse.length} characters');
        print('[CHUNKED TTS] Complete response has ${words.length} words');

        // Split complete response into chunks for faster TTS processing
        List<String> chunks = _splitResponseIntoTTSChunks(cleanedText);

        print(
            '[CHUNKED TTS] Split into ${chunks.length} chunks for TTS processing');

        // Process each chunk sequentially without waiting for previous to complete
        _processChunksSequentially(chunks, context);
      } else {
        // Full text processing mode
        print(
            '[FULL TEXT TTS] Processing complete response: ${completeResponse.length} characters, ${words.length} words');
        await handleFullTextTTS(cleanedText, context);
      }
    } else {
      print('[TTS] Response too short (${words.length} words), skipping TTS');
    }
  }

  /// Process chunks sequentially in background without blocking
  void _processChunksSequentially(
      List<String> chunks, BuildContext context) async {
    for (int i = 0; i < chunks.length; i++) {
      if (!AppState.instance.autoSpeechEnabled) {
        print('[CHUNKED TTS] Auto speech disabled, stopping chunk processing');
        break;
      }

      String chunk = chunks[i].trim();
      if (chunk.isNotEmpty) {
        streamingTtsChunkCount++;
        print(
            '[CHUNKED TTS] Processing chunk ${i + 1}/${chunks.length}: "$chunk"');

        // Start TTS for this chunk immediately (don't await - let it run in background)
        _speakChunkInBackground(chunk, i + 1, context);

        // Small delay between starting each chunk to avoid overwhelming TTS service
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  /// Speak a chunk in background without blocking the next chunk
  void _speakChunkInBackground(
      String chunk, int chunkNumber, BuildContext context) async {
    try {
      print('[CHUNKED TTS] Starting TTS for chunk $chunkNumber: "$chunk"');

      if (AppState.instance.ttsMode.toLowerCase() == 'bhashini') {
        await ttsResponse(chunk, context);
      } else if (AppState.instance.ttsMode.toLowerCase() == 'native') {
        await nativeTTS(chunk);
      } else if (AppState.instance.ttsMode.toLowerCase() == 'resemble ai') {
        await resembleAItts(chunk, context);
      }

      print('[CHUNKED TTS] Completed TTS for chunk $chunkNumber');
    } catch (e) {
      print(
          '[CHUNKED TTS ERROR] Failed to speak chunk $chunkNumber "$chunk": $e');
    }
  }

  /// Split complete response into optimal chunks for TTS processing
  List<String> _splitResponseIntoTTSChunks(String text) {
    List<String> chunks = [];

    // First try to split by sentences
    List<String> sentences = text.split(RegExp(r'(?<=[.!?])\s+'));

    for (String sentence in sentences) {
      if (sentence.trim().isNotEmpty) {
        List<String> words = sentence.trim().split(RegExp(r'\s+'));

        // Optimal chunk size: 8-15 words for natural speech flow
        if (words.length > 15) {
          // Long sentence - split at natural break points
          List<String> phrases = sentence.split(RegExp(r'[,;:]\s+'));

          String currentChunk = '';
          for (String phrase in phrases) {
            if (phrase.trim().isNotEmpty) {
              String testChunk = currentChunk.isEmpty
                  ? phrase.trim()
                  : '$currentChunk, ${phrase.trim()}';
              List<String> testWords = testChunk.split(RegExp(r'\s+'));

              if (testWords.length <= 15) {
                currentChunk = testChunk;
              } else {
                // Add current chunk and start new one
                if (currentChunk.isNotEmpty) {
                  chunks.add(currentChunk);
                }
                currentChunk = phrase.trim();
              }
            }
          }
          // Add remaining chunk
          if (currentChunk.isNotEmpty) {
            chunks.add(currentChunk);
          }
        } else if (words.length >= 3) {
          // Good size sentence - add as single chunk
          chunks.add(sentence.trim());
        }
      }
    }

    // Merge very small chunks (< 3 words) with next chunk
    List<String> optimizedChunks = [];
    String pendingSmallChunk = '';

    for (String chunk in chunks) {
      List<String> chunkWords = chunk.split(RegExp(r'\s+'));

      if (chunkWords.length < 3 && optimizedChunks.isNotEmpty) {
        // Small chunk - merge with previous
        String lastChunk = optimizedChunks.removeLast();
        optimizedChunks.add('$lastChunk $chunk');
      } else {
        // Add pending small chunk if any
        if (pendingSmallChunk.isNotEmpty) {
          optimizedChunks.add('$pendingSmallChunk $chunk');
          pendingSmallChunk = '';
        } else {
          optimizedChunks.add(chunk);
        }
      }
    }

    return optimizedChunks;
  }

  /// Update auto speech setting and notify listeners
  void updateAutoSpeechSetting(bool enabled) {
    print('[AUTO SPEECH] Setting changed to: $enabled');
    AppState.instance.autoSpeechEnabled = enabled;

    if (!enabled) {
      // If auto speech is disabled, stop any current TTS
      stopSpeaking();
      resetStreamingTTS();
    }

    notifyListeners(); // This will trigger UI updates in all ChatBubbles
  }

  Future<void> playAudioChunksSequentially(List<Uint8List> audioChunks) async {
    for (final audioBytes in audioChunks) {
      if (!AppState.instance.autoSpeechEnabled) break;

      await player.stop();

      final completer = Completer<void>();
      StreamSubscription? subscription;

      subscription = player.onPlayerComplete.listen((event) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        subscription?.cancel();
      });

      await player.play(BytesSource(audioBytes));
      await completer.future;
    }
  }
}
