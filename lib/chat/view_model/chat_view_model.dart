import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat/model/chat_history_model.dart';
import 'package:gka/chat/model/chat_message_history.dart';
import 'package:gka/chat/model/get_documents_response.dart';
import 'package:gka/chat/model/get_users_response.dart';
import 'package:gka/chat_bubble.dart';
import 'package:gka/shared/loading_view_model.dart';
import 'package:gka/text_to_speech.dart';
import 'package:gka/utils/app_state.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:uuid/uuid.dart';
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

  // TextToSpeech tts = TextToSpeech();
  FlutterTts tts = FlutterTts();
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

  clearData() {
    promptTemplateIntentMapping.clear();
    // documentIdMapping.clear();
    selectedFile = null;
    isUploading = false;
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
          await repo.fetchUserSessions(context);
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

  Future<bool> updateSessionId(BuildContext context, String sessionId,String newId) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        bool? result = await repo.updateSession(context, sessionId,newId);
        if (result == true) {
          await repo.fetchUserSessions(context);
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

  Future? getMessageHistoryForSession(String sessionId, BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        List<ChatMessageHistory> chatMessageHistoryList =
            await repo.fetchMessageHistory(sessionId, context);
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

  Future? getSessionsForUser(BuildContext context) async {
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        UserSessionModel userSessionModel = await repo.fetchUserSessions(context);
        sessionIdDataMapping.clear();
        if (userSessionModel.status == 200) {
          if (userSessionModel.data.isNotEmpty) {
            userSessionModel.data.sort((a, b) => DateTime.parse(b.insertTs)
                .compareTo(DateTime.parse(a.insertTs)));
            for (var item in userSessionModel.data) {
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
        await repo.fetchMessageHistory(sessionId, context);
        chatDataList.clear();
        if (chatMessageHistoryList != null &&
            chatMessageHistoryList.isNotEmpty) {
          if (chatMessageHistoryList.isNotEmpty) {
            for (ChatMessageHistory item in chatMessageHistoryList) {
              ChatData chatData = ChatData(
                isUser: item.sender == User ? true : false,
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

}
