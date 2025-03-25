import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:gka/utils/secure_storage_util.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gka/text_to_speech.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gka/chat/view/drawer_widget.dart';
import 'package:gka/services/api_provider.dart';
import 'package:gka/utils/app_state.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as platform;
import 'package:uuid/uuid.dart';
import '../utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:developer' as developer;
import 'camera_screen.dart';
import 'main.dart';
import 'message_bubble.dart';
import 'utils/network_utils.dart';

Timer? periodicTimer;

class ChatWindow extends StatefulWidget {
  const ChatWindow({
    Key? key,
    this.isFromHistory,
    this.sessionId,
  }) : super(key: key);

  final bool? isFromHistory;
  final String? sessionId;

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow>
    with AutomaticKeepAliveClientMixin {
  var scrollControllerListView = ScrollController();
  int start = 0;
  int end = 0;
  String? _newVoiceText;
  int prevChatLength = 0;
  int prevChatLengthHistory = 0;
  int c = 0;
  int responseCount = 1;
  String sessionId = "";
  String queryString = "";
  TextEditingController chatController = TextEditingController();
  bool speechToTextOn = false;
  bool isVoiceInitiated = false;
  File? capturedPhoto;
  int timerCounter = 0;
  List<MessageBubble> chatMessages = [];
  FlutterTts tts = FlutterTts();
  String highlightedText = "";
  String remainingText = "";
  bool isllmDropdown = false;

  List<String> loaderMsgList = [
    'Please wait',
    'we are checking',
    'Looking for the result',
    'Hold on a moment',
    'Searching for results',
    'Gathering the data',
    'Just a moment'
  ];

  List<String> langLoaderMsgList = [];
  List<String> llmOptionsList = ['chatgpt-4o', 'gemma2:9b', 'deepseek-r1'];
  List<String> langList = ['English', 'Telugu', 'Hindi'];

  Map<String, String> currentVoice = {
    "name": "en-us-x-iom-local",
    "locale": "en-US"
  };

  TextToSpeechService? textToSpeechService;
  MessageBubble? textToSpeechMessageBubble;
  String summaryData = "";
  bool displayUserText = false;
  bool isLoadingResponse = false;
  OverlayEntry? overlayEntry;
  Timer? periodicTimer;
  Timer? dataTimer;
  Timer? loadingTimer;
  String language = '';
  String langId = '';
  String title = '';
  String dataNotFoundMsg = '';
  String? llmSelected;
  String? langSelected;
  late DatabaseReference ref;

/*  Map<String, String> data = {
    'Which zone had the highest number of leakages in the last 2 months and What is the pipe ID with the most leakages': 'Zone 1 had the highest number of leakages in the last 2 months and the pipe id with the most leakages is HARPIPE01001023.',
    'Which zone had the highest number of leakages in the last two months and What is the pipe ID with the most leakages': 'Zone 1 had the highest number of leakages in the last 2 months and the pipe id with the most leakages is HARPIPE01001023.',
    'How many No Water complaints were received in total': 'A total of 5 \'No Water\' complaints were received.',
    'How many domestic connections are there in zone 5': 'There are 2233 domestic connections in Zone 5.'
  };*/

  @override
  void initState() {
    super.initState();
    AppState.instance.isEnglish = true;
    switch (constants.projectId) {
      case constants.fieldRishiUUID:
        title = constants.appTitle;
        break;
    }
    switch (AppState.instance.language.toLowerCase()) {
      case 'english':
        dataNotFoundMsg = 'Data Not Found';
        loaderMsgList = [
          'Please wait',
          'we are checking',
          'Looking for the result',
          'Hold on a moment',
          'Searching for results',
          'Gathering the data',
          'Just a moment'
        ];
        langId = 'en-US';
        language = 'english';
        break;
      case 'telugu':
        dataNotFoundMsg = 'సమాచారం దొరకట్లేదు';
        loaderMsgList = ['దయచేసి వేచి ఉండండి', 'ఒక్క క్షణం వేచి ఉండండి'];
        langId = 'te-IN';
        language = 'telugu';
        break;
      case 'odia':
        dataNotFoundMsg = 'ତଥ୍ୟ ମିଳିଲା ନାହିଁ';
        loaderMsgList = [
          'ଦୟାକରି ଅପେକ୍ଷା କର',
          'ଆମେ ଯାଞ୍ଚ କରୁଛୁ |',
          'ଫଳାଫଳ ଖୋଜୁଛି |',
          'କିଛି ସମୟ ଧରି ରଖ |',
          'ଗୋଟିଏ କ୍ଷଣ'
        ];
        langId = 'or-IN';
        language = 'odia';
        break;
      case 'hindi':
        dataNotFoundMsg = 'जानकारी नहीं मिली';
        loaderMsgList = [
          'कृपया प्रतीक्षा करें',
          'परिणाम खोज रहे हैं',
          'बस एक क्षण',
          'परिणामों की खोज कर रहे हैं',
          'एक क्षण रुकिए'
        ];
        langId = 'hi-IN';
        dataNotFoundMsg = 'जानकारी नहीं मिली';
        language = 'hindi';
        break;
    }
    _initSpeech();
  }

  @override
  void dispose() {
    dataTimer?.cancel();
    loadingTimer?.cancel();
    tts.stop();
    super.dispose();
  }

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);

  //TextToSpeech textToSpeech = TextToSpeech();

  _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        print("FLKJFJLJF ERROR");
        _stopListening();
      },
      onStatus: (status) {
        print("FLKJFJLJF STATUS ${status}");
      },
    );
    // print("Available voices ${await textToSpeech.getVoiceByLang('hi-IN')}");
    print("Available languages ${await tts.getLanguages}");
    await tts.setLanguage(langId);
    await tts.setSpeechRate(0.5);
    await tts.setVoice(currentVoice);
    print("language::${AppState.instance.language.toLowerCase()}");
    print("lang Id::$langId");
  }

  /// Each time to start a speech recognition session
  _startListening() async {
    var locales = await _speechToText.locales();
    for (int i = 0; i < locales.length; i++) {
      print("LOCALESDSD $i   ${locales[i].name}");
    }

    //for android tab english locale at 5
    print("_onSpeechResult_startListening");
    SpeechRecognitionResult result;
    try {
      await _speechToText.listen(
          onSoundLevelChange: onSoundLevelChange,
          /*localeId: selectedLocale.localeId,*/
          localeId: langId,
          partialResults: true,
          onResult: _onSpeechResult,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 30),
          cancelOnError: true
      );
    } catch (e) {
      print('EXCEPTIONKJSKFJK An exception occurred: $e');
    }

    print("_onSpeechResult_startListening aferfdf ${_speechToText.lastStatus}");
    bool active = _speechToText.isListening;
    tts.stop();
    listeningActive.value = active;
  }

  _startListeningForAutoMode() async {
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
          // onResult: _onSpeechResultForAutoMode,
          pauseFor: const Duration(seconds: 5),
          listenFor: const Duration(seconds: 45),
          cancelOnError: true
      );
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

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    bool active = _speechToText.isListening;
    listeningActive.value = active;
    setState(() {});
  }

  setLogoutSharedPreferences(BuildContext context) async {
    await SecuredStorageUtil.instance.deleteAllSecureData();
    AppState.instance.sessionId = '';
    AppState.instance.userName = '';
    AppState.instance.userId = '';
    AppState.instance.token = '';
    AppState.instance.language = '';
    AppState.instance.isEnglish = false;
    setState(() {});
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    updateChatControllerForSpeech(result.recognizedWords);
    bool active = _speechToText.isListening;
    listeningActive.value = active;
  }

  /*  Future<void> _onSpeechResultForAutoMode(
        SpeechRecognitionResult result) async {
      print("_onSpeechResultForAutoMode ${result.recognizedWords}");
      DatabaseReference ref = FirebaseDatabase.instance.ref(
          "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${autoSessionId}");

      if (result.recognizedWords.toLowerCase() == "hello" && !isVoiceInitiated) {
        await _speechToText.stop();
        await tts.speak("Hello");
        isVoiceInitiated = true;
        setState(() {});
      }
      print("wewewewewe recognizedWords ::${result.recognizedWords}");
      print("wewewewewe isVoiceInitiated ::$isVoiceInitiated");

      if (result.recognizedWords.isNotEmpty &&
          isVoiceInitiated &&
          result.recognizedWords.toLowerCase() != 'hello') {
        await ref.push().set({"is_user": true, "message": result.recognizedWords});
      }
      bool active = _speechToText.isListening;
      tts.stop();
      listeningActive.value = active;
    }*/

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        bool? result = await showSessionDialog();
        if (result != null && result) {
          tts.stop();
          await _speechToText.stop();
          periodicTimer?.cancel();
          Navigator.pop(context);
        }
        return false;
      },
      child: Scaffold(
        drawer: DrawerWidget(
          // isFirstTime: widget.isFirstTime,
          sessionId: widget.sessionId!,
        ),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0XFF55A18F),
          titleSpacing: 2,
          title: Image.asset(
            'assets/images/appbar_heading.png',
          ),
          /*actions: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              // Adjust spacing as needed
              child: FlutterSwitch(
                width: 60.0,
                height: 30.0,
                valueFontSize: 10.0,
                toggleSize: 18.0,
                value: AppState.instance.isEnglish,
                borderRadius: 30.0,
                // padding: 2.0,
                activeColor: Colors.black26,
                inactiveColor: Colors.black26,
                activeText: 'ENG',
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.white,
                inactiveText: 'తెలుగు',
                showOnOff: true,
                onToggle: (val) async {
                  setState(() {
                    AppState.instance.isEnglish = val;
                    if (AppState.instance.isEnglish) {
                      AppState.instance.language = 'English';
                      langId = 'en-US';
                      dataNotFoundMsg = 'Data Not found';
                      language = 'english';
                      currentVoice = {
                        "name": "en-us-x-iom-local",
                        "locale": "en-US"
                      };
                      Fluttertoast.showToast(
                          msg: "Switched to ${AppState.instance.language}");
                    } else {
                      */
          /*AppState.instance.language = 'Hindi';
                      langId = 'hi-IN';
                      dataNotFoundMsg = 'जानकारी नहीं मिली';
                      language = 'hindi';
                      currentVoice = {
                        "name": "hi-in-x-hid-network",
                        "locale": "hi-IN"
                      };*/
          /*
                      AppState.instance.language = 'Telugu';
                      langId = 'te-IN';
                      dataNotFoundMsg = 'సమాచారం దొరకలేదు';
                      language = 'telugu';
                      currentVoice = {
                        "name": "te-in-x-tef-local",
                        "locale": "te-IN"
                      };

                      Fluttertoast.showToast(
                          msg: "Switched to ${AppState.instance.language}");
                    }
                  });
                  await _initSpeech();
                },
              ),
            ),
          ],*/
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  !AppState.instance.isListeningMode
                      ? Expanded(
                          child: StreamBuilder(
                            stream: FirebaseDatabase.instance.ref("${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}").onValue,
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                List<ChatBubble> messageList = [];
                                List<ChatBubble> tempList = [];
                                var data = (snapshot.data! as DatabaseEvent).snapshot.value ?? {};
                                data = data as Map<dynamic, dynamic>;
                                Map<String, String> dataTsMapping = {};
                                dataTimer?.cancel();
                                loadingTimer?.cancel();
                                var sortedByKeyMap = Map.fromEntries(data
                                    .entries
                                    .toList()
                                  ..sort((e1, e2) => e1.key.compareTo(e2.key)));

                                List<String> thoughtsList = [];
                                List<String> followUpQuestionsList = [];
                                Map<String, String> cotMapping = {};
                                Map<String, String> maps = {};

                                sortedByKeyMap.forEach((key, value) async {
                                  if (key != "cart") {
                                    final datalast =
                                        Map<String, dynamic>.from(value);
                                    if (datalast['is_user']) {
                                      thoughtsList.clear();
                                      maps.clear();
                                      cotMapping.clear();
                                      messageList.add(ChatBubble(
                                        isMapView: true,
                                        expandChainOfThought: false,
                                        text: datalast['message'] ?? '',
                                        isUser: datalast['is_user'],
                                        imageUrl: datalast['image_url'] ?? '',
                                        tableColumnData:
                                            datalast['sql_df_columns'],
                                        tableRowData:
                                            datalast['sql_df_values'] != null
                                                ? jsonDecode(
                                                    datalast['sql_df_values'])
                                                : null,
                                        logMessage: datalast['log'] ?? '',
                                        hasErrorLog: false,
                                        timestampMapping: dataTsMapping,
                                        chainOfThoughts: {},
                                        token: datalast['token'] ?? '',
                                        followUpQuestions: [],
                                      ));
                                    } else {
                                      if (datalast['chain_of_thought'] !=
                                          null) {
                                        (datalast['chain_of_thought'] as Map)
                                            .forEach((key, value) {
                                          maps[key.toString()] =
                                              value.toString();
                                        });
                                        cotMapping.addAll(maps);
                                      }
                                      if (datalast['follow_up_questions'] !=
                                          null) {
                                        List<Object?> followUpQuestions =
                                            datalast['follow_up_questions'];
                                        followUpQuestionsList =
                                            followUpQuestions
                                                .map((item) => item.toString())
                                                .toList();
                                      }
                                      // print("follow:$followUpQuestionsList");

                                      if (datalast['is_valid_token'] != null &&
                                          datalast['is_limit_exceeded'] !=
                                              null) {
                                        if (!datalast['is_valid_token'] ||
                                            datalast['is_limit_exceeded']) {
                                          Fluttertoast.showToast(msg: "Session Expired");
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            Navigator.pop(context);
                                          });
                                        }
                                      }
                                      // messageList.last.expandChainOfThought = false;
                                      messageList.add(ChatBubble(
                                        isMapView: true,
                                        expandChainOfThought: false,
                                        text: datalast['message'] ?? '',
                                        isUser: datalast['is_user'],
                                        imageUrl: datalast['image_url'] ?? '',
                                        tableColumnData:
                                            datalast['sql_df_columns'],
                                        tableRowData:
                                            datalast['sql_df_values'] != null
                                                ? jsonDecode(
                                                    datalast['sql_df_values'])
                                                : null,
                                        logMessage: datalast['log'] ?? '',
                                        hasErrorLog: false,
                                        timestampMapping: dataTsMapping,
                                        chainOfThoughts:
                                            Map<String, String>.from(
                                                cotMapping),
                                        followUpQuestions:
                                            followUpQuestionsList,
                                        token: datalast['token'] ?? '',
                                      ));
                                    }
                                  }
                                });

                                if (widget.isFromHistory != null &&
                                    widget.isFromHistory == true &&
                                    c == 0) {
                                  if (messageList.isNotEmpty &&
                                      !messageList[messageList.length - 1]
                                          .isUser &&
                                      messageList.length > prevChatLength) {
                                    c++;
                                  }
                                } else {
                                  if (messageList.isNotEmpty &&
                                      !messageList[messageList.length - 1]
                                          .isUser &&
                                      messageList[messageList.length - 1]
                                          .text
                                          .isNotEmpty &&
                                      messageList.length > prevChatLength) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      showLoader.value = false;
                                    });

                                    // tts.speak(messageList[messageList.length - 1].text);
                                    _speakMessage(
                                        messageList[messageList.length - 1]
                                            .text);
                                  }
                                  prevChatLength = messageList.length;
                                  if (messageList.isNotEmpty &&
                                      messageList[messageList.length - 1]
                                          .isUser) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      showLoader.value = true;
                                      tts.stop();
                                    });
                                  }

                                  /*  loadingTimer =
                                        Timer(const Duration(seconds: 4), () {
                                      int randomIndex =
                                          Random().nextInt(loaderMsgList.length);
                                      if (showLoader.value) {
                                        tts.speak(loaderMsgList[randomIndex]);
                                      }
                                    });*/

                                  dataTimer = Timer(
                                      const Duration(seconds: 180), () async {
                                    if (showLoader.value) {
                                      DatabaseReference ref =
                                          FirebaseDatabase.instance.ref(
                                              "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}");
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) async {
                                        showLoader.value = false;
                                        String timeStamp = DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString();
                                        await ref.child(timeStamp).set({
                                          "is_user": false,
                                          "message": dataNotFoundMsg,
                                        });
                                      });
                                      await tts.speak(dataNotFoundMsg);
                                    }
                                  });
                                }

                                if (messageList.isNotEmpty) {
                                  messageList.last.expandChainOfThought = true;
                                }
                                List<Map<String, dynamic>> mappedData = [];
                                Map<String, dynamic>? currentQuestion = {};

                                for (int i = 0; i < messageList.length; i++) {
                                  if (messageList[i].isUser) {
                                    currentQuestion = {
                                      'isUser': messageList[i].isUser,
                                      'text': messageList[i].text,
                                      'image_url':
                                          messageList[i].imageUrl ?? '',
                                      'cots': {},
                                      'followQns': [],
                                    };
                                    mappedData.add(currentQuestion);
                                  } else {
                                    if (currentQuestion != null) {
                                      if (messageList[i].chainOfThoughts !=
                                              null &&
                                          messageList[i]
                                              .chainOfThoughts!
                                              .isNotEmpty) {
                                        currentQuestion['cots'] =
                                            messageList[i].chainOfThoughts;
                                      }
                                    }
                                    if (currentQuestion != null &&
                                        messageList[i].text!.isNotEmpty) {
                                      Map<String, dynamic> data = {
                                        'isUser': messageList[i].isUser,
                                        'text': messageList[i].text.toString(),
                                        'image_url':
                                            messageList[i].imageUrl ?? '',
                                        'cots':
                                            messageList[i].chainOfThoughts ??
                                                '',
                                        'followQns':
                                            messageList[i].followUpQuestions
                                      };
                                      mappedData.add(data);
                                    }
                                  }
                                }

                                String message;
                                String image;
                                bool currentIsUser;
                                Map<String, String> cotsMap = {};
                                List<String> questions = [];

                                for (int i = 0; i < mappedData.length; i++) {
                                  currentIsUser = mappedData[i]['isUser'];
                                  message = mappedData[i]['text'];
                                  cotsMap = Map<String, String>.from(
                                      mappedData[i]['cots']);
                                  image = mappedData[i]['image_url'] ?? '';
                                  bool cotExpand = false;

                                  questions = List<String>.from(
                                      mappedData[i]['followQns']);
                                  if (i == (mappedData.length - 1) &&
                                      currentIsUser) {
                                    cotExpand = true;
                                  }

                                  tempList.add(ChatBubble(
                                    text: message,
                                    isUser: currentIsUser,
                                    chainOfThoughts: cotsMap,
                                    imageUrl: image,
                                    expandChainOfThought: cotExpand,
                                    followUpQuestions: questions,
                                    isMapView: false,
                                  ));
                                }

                                return ListView.builder(
                                  reverse: true,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  controller: scrollControllerListView,
                                  addAutomaticKeepAlives: true,
                                  itemBuilder: (context, index) {
                                    if (index < tempList.length) {
                                      return Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: tempList[
                                            tempList.length - 1 - index],
                                      );
                                    }
                                    return null;
                                  },
                                  itemCount: tempList.length,
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        )
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ValueListenableBuilder(
                        valueListenable: showLoader,
                        builder: (context, value, _) {
                          if (value) {
                            return LoadingAnimationWidget.waveDots(
                                color: const Color(0XFF55A18F), size: 40);
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  !AppState.instance.isListeningMode
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: bottomBar(),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            /*const Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Center(
                    child: SizedBox(
                      height: 150,
                      width: 200,
                      child: Image(
                        image: AssetImage('assets/images/appbar_heading.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),*/
          ],
        ),
      ),
    );
  }

  _speechButton() {
    return ValueListenableBuilder(
      valueListenable: listeningActive,
      builder: (context, value, _) {
        return IconButton(
          onPressed: !value ? _startListening : _stopListening,
          icon: Icon(
            !value ? Icons.mic_off : Icons.mic,
            color: Colors.grey,
          ),
          tooltip: 'Listen',
        );
      },
    );
  }

  _chatInput() {
    return Column(
      children: [
        TextFormField(
          controller: chatController,
          maxLines: null,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Ask AI anything...',
            hintStyle: constants.lightGrey2_14W400,
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF4BA164),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            prefixIcon: _speechButton(),
            suffixIcon: _sendButton(),
          ),
        ),
        // _dropdownInsideField(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _dropdownInsideField(!isllmDropdown)),
            const SizedBox(width: 8), // Spacing between dropdowns
            Expanded(child: _dropdownInsideField(isllmDropdown)),
          ],
        ),
      ],
    );
  }

  Widget bottomBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chatInput(),
          // _dropdownInsideField(),
        ],
      ),
    );
  }

  Widget _dropdownInsideField(bool isLlm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      // Align with input field
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(isLlm ? 'Select LLM' : 'Select Language',
              style: constants.grey12W400),
          value: isLlm ? llmSelected : langSelected,
          isExpanded: true,
          onChanged: (newValue) async {
            setState(() {
              if (isLlm) {
                llmSelected = newValue!;
              } else {
                langSelected = newValue!;
                AppState.instance.language = langSelected ?? '';
              }
            });

            if (!isLlm) {
              if (AppState.instance.language.toLowerCase() == 'telugu') {
                AppState.instance.language = 'Telugu';
                langId = 'te-IN';
                dataNotFoundMsg = 'సమాచారం దొరకలేదు';
                language = 'telugu';
                currentVoice = {"name": "te-in-x-tef-local", "locale": "te-IN"};
              }
              if (AppState.instance.language.toLowerCase() == 'hindi') {
                AppState.instance.language = 'Hindi';
                langId = 'hi-IN';
                dataNotFoundMsg = 'जानकारी नहीं मिली';
                language = 'hindi';
                currentVoice = {
                  "name": "hi-in-x-hid-network",
                  "locale": "hi-IN"
                };
              }
              if (AppState.instance.language.toLowerCase() == 'english') {
                AppState.instance.language = 'English';
                langId = 'en-US';
                dataNotFoundMsg = 'Data Not found';
                language = 'english';
                currentVoice = {"name": "en-us-x-iom-local", "locale": "en-US"};
              }
              print("12345 current voice :: ${currentVoice}");
              await tts.setVoice(currentVoice);
              await tts.setLanguage(langId);
              await tts.setSpeechRate(0.5);
              Fluttertoast.showToast(
                  msg: "Switched to ${AppState.instance.language}");
            }
          },
          items: (isLlm ? llmOptionsList : langList)
              .map(
                  (model) => DropdownMenuItem(value: model, child: Text(model)))
              .toList(),
        ),
      ),
    );
  }

  _speakMessage(String text) async {
    String plainText = _extractPlainText(text.trim());
    await tts.speak(plainText);
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

  _sendButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        capturedPhoto == null
            ? CameraWidget(saveCapturedPhoto: saveCapturedPhoto)
            : Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      capturedPhoto = null;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 2),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(capturedPhoto!.path)),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ValueListenableBuilder(
          valueListenable: showLoader,
          builder: (context, value, _) {
            return IconButton(
                icon: Icon(Icons.send,
                    color: showLoader.value
                        ? Colors.grey
                        : const Color(0XFF55A18F)),
                onPressed: showLoader.value
                    ? null
                    : () async {
                        addUserUploadedImageToChat();
                        addUserMessageToChat(chatController.text);
                        if (chatController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Please enter your question.");
                        } else {
                          String? imageUrl = '';
                          if (capturedPhoto != null) {
                            // imageUrl = await uploadMedia(context, capturedPhoto!.path);
                            imageUrl = await uploadMediaToS3(capturedPhoto);
                          }
                          await insertDataIntoDb(imageUrl, chatController.text);
                        }
                      });
          },
        ),
      ],
    );
  }

  /* _speechButton() {
    return Positioned(
      left: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: listeningActive,
            builder: (context, value, _) {
              return IconButton(
                onPressed: !value ? _startListening : _stopListening,
                icon: Icon(
                  !value ? Icons.mic_off : Icons.mic,
                  color: Colors.grey,
                ),
                tooltip: 'Listen',
              );
            },
          ),
        ],
      ),
    );  }

  _chatInput() {
    return TextFormField(
      controller: chatController,
      maxLines: null,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Ask AI anything...',
        hintStyle: constants.lightGrey2_14W400,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF4BA164),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.fromLTRB(50, 4, 10, 4),
        suffixIcon: _sendButton(),
      ),
    );
  }*/

  void updateChatControllerForSpeech(String text) {
    print("121212121 text:: $text");
    if (text.contains('తప్రాణా')) {
      text = text.replaceAll('తప్రాణా', 'తప్రానా');
    }
    if (text.contains('తప్పానా')) {
      text = text.replaceAll('తప్పానా', 'తప్రానా');
    }
    if (text.contains('తప్రాన')) {
      text = text.replaceAll('తప్రాన', 'తప్రానా');
    }
    if (text.contains('తప్రాణ')) {
      text = text.replaceAll('తప్రాణ', 'తప్రానా');
    }
    if (text.contains('తప్పురానా')) {
      text = text.replaceAll('తప్పురానా', 'తప్రానా');
    }
    if (text.contains('తప్పు రానా')) {
      text = text.replaceAll('తప్పు రానా', 'తప్రానా');
    }
    chatController.text = text;
    setState(() {});
  }

  saveCapturedPhoto(XFile photo) {
    capturedPhoto = File(photo.path);
    setState(() {});
  }

  addUserUploadedImageToChat() {
    MessageBubble messageBubble = MessageBubble(
      image: capturedPhoto,
      user: true,
      textToSpeechEnabled: false,
      isResponseLoading: false,
      isTextToSpeechRunning: false,
    );
    chatMessages.add(messageBubble);
    // chatController.clear();
    setState(() {});
  }

  addUserMessageToChat(String message) {
    MessageBubble messageBubble = MessageBubble(
      message: message,
      user: true,
      textToSpeechEnabled: true,
      isResponseLoading: false,
      isTextToSpeechRunning: false,
    );
    chatMessages.add(messageBubble);
    setState(() {});
  }

  Future<String?> uploadMedia(BuildContext context, String imagePath) async {
    if (await networkUtils.hasActiveInternet()) {
      try {
        Map<String, String> params = {};
        params = {"bucket_name": "crop_bucket"};
        String? url =
            await ApiProvider.instance.uploadMedia(params, imagePath, 'image');
        if (url != null && url.isNotEmpty) {
          return url;
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
    setState(() {});
    return null;
  }

  Future<String> uploadMediaToS3(File? file) async {
    String imageUrl = "";
    try {
      String? value = await AwsS3.uploadFile(
        accessKey: constants.accessKey,
        secretKey: constants.secretKey,
        file: File(file!.path),
        bucket: constants.bucket,
        region: constants.region,
        destDir: constants.s3Filefolder,
      );
      if (value != null) {
        imageUrl = value;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: constants.genericErrorMsg);
      return imageUrl;
    }
    print("IMAGE URLL : $imageUrl");
    return imageUrl;
  }

  showSessionDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Do you want to end the session?',
            style: constants.black16W500,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // bool? result = await viewModel.endSession();
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> insertDataIntoDb(String? imageUrl, String text) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}");

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    await ref.child(timeStamp).set({
      "is_user": true,
      "message": text,
      "image_url": imageUrl ?? '',
      "language": AppState.instance.language.toLowerCase(),
      // "llm": 'deepseek-v2:latest',
      "llm": 'chatgpt-4o',
      "model_uuid": AppState.instance.modelUUID,
      "mode": '',
      "token": AppState.instance.token,
      "sm_enabled": true,
    });

    chatController.clear();
    capturedPhoto = null;

    /*   await Future.delayed(const Duration(seconds: 3));

    String timeStampUpdated = DateTime.now().millisecondsSinceEpoch.toString();
    String image = '';

    if (text == 'Give inflow trend of Hirakud reservoir for next week') {
      image = 'assets/images/hirakud.png';
    }

    await ref
        .child(timeStampUpdated)
        .set({"is_user": false, "message": data[text], "image_url": image});*/

    setState(() {});
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground',
      'MY FOREGROUND SERVICE',
      description: 'This channel is used for important notifications.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (platform.Platform.isAndroid || platform.Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('ic_bg_service_small'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        // auto start service
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        // initialNotificationTitle: 'AWESOME SERVICE',
        // initialNotificationContent: 'Initializing',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        // onForeground: onStart,
        onBackground: null,
      ),
    );
  }

  Future<void> initializeSpeechToText(String sessionId) async {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyD4kQrxxhyhqQwRjhnKRVJPgpT9jkuadUo',
      appId: '1:1062998944432:ios:597dab286cd6fc12f22975',
      messagingSenderId: '1062998944432',
      projectId: 'apwrims---chatbot',
      storageBucket: 'apwrims---chatbot.appspot.com',
      iosBundleId: 'com.vassar.fieldrishi',
    ));

    bool available = await _speechToText.initialize(
      onStatus: (status) async {
        print('Status: $status');
        /*  if (status == 'notListening') {
          await startListeningBg();
        }*/
      },
      onError: (error) async {
        print('Error: $error');
        // await startListeningBg();
      },
    );

    print("wewewewewew AppState.instance.triggeredWord ::  ${AppState.instance.triggeredWord}");
    print("wewewewewew session $sessionId");

    if (available && AppState.instance.triggeredWord == "") {
      // AppState.instance.triggeredWord = await startListenings(sessionId);
    }

    if (available && AppState.instance.triggeredWord.isNotEmpty) {
      // await startListeningToYes(sessionId, AppState.instance.triggeredWord);
    }

    /*  bool initialized = await speechToText.initialize(
      onStatus: (status) async {
        print('Status: $status');
        print('sessionId: $sessionId');
        if (status == 'notListening') {
          //await speechToText.stop();
          // await startListenings(sessionId);
        }
      },
      onError: (error) async {
        print('Error: $error');
        //await speechToText.stop();
        await startListenings(sessionId);
      },
    );

    await startListenings(sessionId);*/
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> speakMsg(String text) async {
    if (_newVoiceText != null) {
      await tts.awaitSpeakCompletion(true);
      await tts.speak(_newVoiceText!);
    }
  }
/* Future<String> translateText(
        String text, String language, bool isInserted) async {
      String _translatedText = '';
      final onDeviceTranslator = isInserted
          ? GoogleMlKit.nlp.onDeviceTranslator(
              sourceLanguage: TranslateLanguage.hindi,
              targetLanguage: TranslateLanguage.english,
            )
          : GoogleMlKit.nlp.onDeviceTranslator(
              sourceLanguage: TranslateLanguage.english,
              targetLanguage: TranslateLanguage.hindi,
            );

      final result = await onDeviceTranslator.translateText(text);
      setState(() {
        _translatedText = result;
      });

      await onDeviceTranslator.close();
      return _translatedText;
    }*/
}

@pragma('vm:entry-point')
onStart(ServiceInstance service) async {
  String autoSessionId = const Uuid().v4();
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  String sessionId = const Uuid().v4();

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  periodicTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        /*      flutterLocalNotificationsPlugin.show(
            888,
            'COOL SERVICE',
            'Awesome ${DateTime.now()}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'my_foreground',
                'MY FOREGROUND SERVICE',
                icon: 'ic_bg_service_small',
                ongoing: true,
              ),
            ),
          );*/

        /* // if you don't using custom notification, uncomment this
          service.setForegroundNotificationInfo(
            title: "Agri Data",
            content: "Updated at ${DateTime.now()}",
          );*/
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (platform.Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (platform.Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
    if (autoSessionId != null && autoSessionId!.isNotEmpty) {
      await initializeSpeechToText(autoSessionId!);
    } else {
      Fluttertoast.showToast(msg: "Something went wrong, please try again");
    }
  });
}

Future<void> initializeSpeechToText(String sessionId) async {
  print(("startListeningToHello: starting listening"));
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyD4kQrxxhyhqQwRjhnKRVJPgpT9jkuadUo',
    appId: '1:1062998944432:ios:597dab286cd6fc12f22975',
    messagingSenderId: '1062998944432',
    projectId: 'apwrims---chatbot',
    storageBucket: 'apwrims---chatbot.appspot.com',
    iosBundleId: 'com.vassar.fieldrishi',
  ));

  bool available = await speechToText.initialize(
    onStatus: (status) async {
      print('Status: $status');
      /*  if (status == 'notListening') {
          await startListeningBg();
        }*/
    },
    onError: (error) async {
      print('Error: $error');
      // await startListeningBg();
    },
  );

  if (available && AppState.instance.triggeredWord == "") {
    AppState.instance.triggeredWord = await startListenings(sessionId);
  }

  if (available && AppState.instance.triggeredWord.isNotEmpty) {
    await startListeningToYes(sessionId, AppState.instance.triggeredWord);
  }
}

Future<void> startListeningToYes(String sessionId, String word) async {
  print("startListeningToYes");
  print("wewewewewew trigger word :: ${AppState.instance.triggeredWord}");
  await speechToText.stop();
  print("wewewewewew speechToText.isListening:: ${speechToText.isListening}");
  DatabaseReference ref = FirebaseDatabase.instance.ref("CHAT_BOT_CHANGELOG/${constants.projectId}/${AppState.instance.userId}/$sessionId");
  SpeechRecognitionResult result;

  await speechToText.listen(
      partialResults: false,
      onResult: (data) async {
        result = data;
        print("wewewewewew 111111-input::${result.recognizedWords}");
        if (result.recognizedWords.isNotEmpty &&
            result.recognizedWords.toLowerCase() == "yes") {
          print("wewewewewew 111111-yes::${result.recognizedWords}");
          await speechToText.stop();
          await ref.push().set({
            "is_user": true,
            "event_name": 'CONTINUOUS_LISTEN_MODE',
            "trigger_word": '${AppState.instance.triggeredWord}'
          });
          print("111111-pushed");
          /* await ref.push().set({
              "is_user": false,
              "event_name": 'CONTINUOUS_LISTEN_MODE',
              "changelog": 'No Change in $AppState.instance.triggeredWord Data'
            });*/
          Future.delayed(const Duration(seconds: 2), () async {
            print("wewewewewe AppState.instance.triggeredWord after completion::${AppState.instance.triggeredWord}");
            await ref.orderByKey().limitToLast(1).once().then((event) async {
              DataSnapshot snapshot = event.snapshot;
              print("values::${snapshot.value}");
              if (snapshot.value != null) {
                dynamic values = snapshot.value;
                values.forEach((key, value) async {
                  if (!value['is_user']) {
                    String responseMessage = value['changelog'] ?? '';
                    AppState.instance.triggeredWord = "";
                    await tts.speak(responseMessage);
                  }
                });
              }
            });
          });
        }
      });
  // await startListenings(sessionId);
}
