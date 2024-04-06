import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat_bubble.dart';
import 'package:gka/text_to_speech.dart';
import 'package:gka/utils/app_state.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:uuid/uuid.dart';
import '../../login/model/login_api_response_model.dart' as login;
import '../../login/model/login_api_response_model.dart';
import '../../message_bubble.dart';

class ChatViewModel extends ChangeNotifier {
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

  final SpeechToText _speechToText = SpeechToText();
  ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);

  // ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  bool speechEnabled = false;

  Future<String?> createSession() async {
    try {
      String url = constants.ngrok;
      Content data = login.Content(
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
      );
      print("Request data before encode::$data");
      String requestBody = jsonEncode(data);
      Response response = await post(
        Uri.parse(url),
        body: requestBody,
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
    /*   String uuid = const Uuid().v4();
    sessionId = uuid;
    isFirstTime = true;
    notifyListeners();
    return uuid;*/
    return null;
  }

  void updateFirstTimeValue() {
    isFirstTime = true;
    notifyListeners();
  }

  void stopListening() async {
    await _speechToText.stop();
    bool active = _speechToText.isListening;
    listeningActive.value = active;
    notifyListeners();
  }

  /// Each time to start a speech recognition session
  startListening() async {
    var locales = await _speechToText.locales();
    for (int i = 0; i < locales.length; i++) {
      print("LOCALESDSD $i   ${locales[i].name}");
    }
    // 34 for hindi
    // 55 for Spanish

    // 23 for Ipad English
    //var selectedLocale = locales[5];

    //for android tab english locale at 5
    print("_onSpeechResult_startListening");
    SpeechRecognitionResult result;
    try {
      await _speechToText.listen(
          onSoundLevelChange: onSoundLevelChange,
          /*localeId: selectedLocale.localeId,*/
          partialResults: false,
          onResult: onSpeechResult,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 20),
          cancelOnError: true);
    } catch (e) {
      print('EXCEPTIONKJSKFJK An exception occurred: $e');
    }

    print("_onSpeechResult_startListening aferfdf ${_speechToText.lastStatus}");
    bool active = _speechToText.isListening;
    tts.stop();
    listeningActive.value = active;
    notifyListeners();
  }

  startListeningForAutoMode() async {
    var locales = await _speechToText.locales();
    for (int i = 0; i < locales.length; i++) {
      print("LOCALESDSD $i   ${locales[i].name}");
    }

    print("_onSpeechResult_startListening_auto_mode");
    SpeechRecognitionResult result;
    try {
      await _speechToText.listen(
          onSoundLevelChange: onSoundLevelChange,
          /*localeId: selectedLocale.localeId,*/
          partialResults: false,
          onResult: onSpeechResultForAutoMode,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 15),
          cancelOnError: true);
    } catch (e) {
      print('EXCEPTIONKJSKFJK An exception occurred: $e');
    }

    print(
        "_onSpeechResult_startListening_auto_mode aferfdf ${_speechToText.lastStatus}");
    bool active = _speechToText.isListening;
    tts.stop();
    listeningActive.value = active;
  }

  dynamic Function(double)? onSoundLevelChange(double value) {
    print("onSoundLevelChange  $value");
    return null;
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  Future<void> onSpeechResult(SpeechRecognitionResult result) async {
    print("_onSpeechResult ${result.recognizedWords}");
    await updateChatControllerForSpeech(result.recognizedWords);
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("CHAT_BOT_ONDEMAND_QUERY_DATA/$sessionId}");
    toggleValue ? llmType = "internal" : llmType = "external";
    print("llmType::${llmType}");
    // TransliterationResponse? response = await Transliteration.transliterate(result.recognizedWords, Languages.TELUGU);
    // final translatedText =response?.transliterationSuggestions[0].toString();
    // print("translated::$translatedText");
    await ref.push().set({
      "isUser": true,
      "message": result.recognizedWords,
      "mediaUrl": '',
      "llm_type": llmType
    });
    // await ref.push().set({"isUser": false, "message": "Hello how are you"});
    // if(result.recognizedWords.toLowerCase() == "give summary"){
    //   await ref.push().set({"isUser": false, "message": "Summaryy"});
    // }
    // await ref.push().set({"isUser": false, "message": "Response ${responseCount++}"});
    /* String responseMsg = "Cheppandi";
    TransliterationResponse? _response = await Transliteration.transliterate(responseMsg, Languages.TELUGU);
    final translatedResponse = _response?.transliterationSuggestions[0].toString();
    print("translated::$translatedText");
    await ref.push().set({"isUser": true, "message": translatedText});
    await ref.push().set({"isUser": false, "message": translatedResponse});*/
    bool active = _speechToText.isListening;
    listeningActive.value = active;
    notifyListeners();
  }

  Future<void> onSpeechResultForAutoMode(SpeechRecognitionResult result) async {
    print("_onSpeechResultForAutoMode ${result.recognizedWords}");
    print("_onSpeechResultForAutoMode autoSessionId ${autoSessionId}");
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("CHAT_BOT_ONDEMAND_QUERY_DATA/${autoSessionId}");

    if (result.recognizedWords.toLowerCase() == "hello" && !isVoiceInitiated) {
      await _speechToText.stop();
      await tts.speak("Hello");
      isVoiceInitiated = true;
      notifyListeners();
    }
    print("wewewewewe recognizedWords ::${result.recognizedWords}");
    print("wewewewewe isVoiceInitiated ::$isVoiceInitiated");

    if (result.recognizedWords.isNotEmpty &&
        isVoiceInitiated &&
        result.recognizedWords.toLowerCase() != 'hello') {
      await ref.push().set({"isUser": true, "message": result.recognizedWords});
      await ref.push().set({"isUser": false, "message": "response"});
    }

    bool active = _speechToText.isListening;
    listeningActive.value = active;
  }

  updateChatControllerForSpeech(String text) {
    chatController.text = text;
    notifyListeners();
  }

  void initSpeech() async {
    speechEnabled = await _speechToText.initialize(
      onError: (error) {
        print("FLKJFJLJF ERROR");
        stopListening();
      },
      onStatus: (status) {
        print("FLKJFJLJF STATUS ${status}");
      },
    );

    //print("Available voices ${await tts.getVoice()}");
    print("Available languages ${await tts.getLanguages}");
    await tts.setLanguage("en-US");
  }
}
