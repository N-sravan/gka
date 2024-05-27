import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gka/chat/view/drawer_widget.dart';
import 'package:gka/services/api_provider.dart';
import 'package:gka/utils/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transliteration/response/transliteration_response.dart';
import 'package:transliteration/transliteration.dart';
import 'dart:io' as platform;
import 'package:uuid/uuid.dart';
import '../utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat_bubble.dart';
import 'package:gka/text_to_speech.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'dart:developer' as developer;
import 'camera_screen.dart';
import 'chat/view/speech_to_text.dart';
import 'main.dart';
import 'message_bubble.dart';
import 'utils/network_utils.dart';

Timer? periodicTimer;

class ChatWindow extends StatefulWidget {
  const ChatWindow({
    Key? key,
    required this.isFirstTime,
    required this.finishSession,
    required this.sessionId,
    this.isFromHistory,
  }) : super(key: key);

  final bool isFirstTime;
  final Function(bool finishSession) finishSession;
  final String sessionId;
  final bool? isFromHistory;

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow>
    with AutomaticKeepAliveClientMixin {
  var scrollControllerListView = ScrollController();
  int prevChatLength = 0;
  int prevChatLengthHistory = 0;
  int c = 0;

  // TextToSpeech tts = TextToSpeech();
  int responseCount = 1;
  String sessionId = "";
  String queryString = "";
  TextEditingController chatController = TextEditingController();
  bool speechToTextOn = false;
  bool isVoiceInitiated = false;
  File? capturedPhoto;
  int timerCounter = 0;
  List<MessageBubble> chatMessages = [];
  TextToSpeech textToSpeech = TextToSpeech();
  FlutterTts tts = FlutterTts();

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

  TextToSpeechService? textToSpeechService;
  MessageBubble? textToSpeechMessageBubble;
  String summaryData = "";
  bool displayUserText = false;
  bool isLoadingResponse = false;
  bool _toggleValue = true;
  OverlayEntry? overlayEntry;
  Timer? periodicTimer;
  Timer? dataTimer;
  Timer? loadingTimer;
  String language = '';
  String langId = '';
  String title = '';
  String dataNotFoundMsg = '';
  late DatabaseReference ref;

  @override
  void initState() {
    super.initState();
    switch (constants.projectId) {
      case constants.odishaUUID:
        title = 'GoWater Bot';
        break;
      case constants.apwrimsUUID:
        title = 'AquaMIND Assistant';
        break;
      case constants.kaleswaramUUID:
        title = 'Kaleswaram Bot';
        break;
      case constants.tnwrimsUUID:
        title = 'TNWRIMS Bot';
        break;
    }
    switch (AppState.instance.language) {
      case 'English':
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
      case 'Telugu':
        dataNotFoundMsg = 'సమాచారం దొరకట్లేదు';
        loaderMsgList = ['దయచేసి వేచి ఉండండి', 'ఒక్క క్షణం వేచి ఉండండి'];
        langId = 'te-IN';
        language = 'telugu';
        break;
      case 'Odia':
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

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        print("FLKJFJLJF ERROR");
        _stopListening();
      },
      onStatus: (status) {
        print("FLKJFJLJF STATUS ${status}");
      },
    );

    // print("Available voices ${await textToSpeech.getVoiceByLang('ta-IN')}");
    print("Available languages ${await tts.getLanguages}");
    await tts.setLanguage("en-US");
  }

  /// Each time to start a speech recognition session
  _startListening() async {
    var locales = await _speechToText.locales();
    for (int i = 0; i < locales.length; i++) {
      print("LOCALESDSD $i   ${locales[i].name}");
    }

    // AppState.instance.isOriyaSelected ? langId = 'te-IN' : langId = 'en-US';

    //for android tab english locale at 5
    print("_onSpeechResult_startListening");
    SpeechRecognitionResult result;
    try {
      await _speechToText.listen(
          onSoundLevelChange: onSoundLevelChange,
          /*localeId: selectedLocale.localeId,*/
          localeId: langId,
          partialResults: false,
          onResult: _onSpeechResult,
          pauseFor: const Duration(seconds: 5),
          listenFor: const Duration(seconds: 35),
          cancelOnError: true);
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
          listenFor: const Duration(seconds: 35),
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

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    bool active = _speechToText.isListening;
    listeningActive.value = active;
    setState(() {});
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    print("_onSpeechResult ${result.recognizedWords}");
    updateChatControllerForSpeech(result.recognizedWords);
    /*  DatabaseReference ref = FirebaseDatabase.instance.ref(
        "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}");

    String? message = '';
    print("session id::$sessionId");
    if (language == 'odia') {
      TransliterationResponse? response = await Transliteration.transliterate(
          result.recognizedWords, Languages.ORIYA);
      final translatedText = response?.transliterationSuggestions[0].toString();
      message = translatedText;
      print("translated::$translatedText");
    } else {
      message = result.recognizedWords;
    }
    await ref.push().set({
      "isUser": true,
      "message": message,
      "mediaUrl": '',
      'language': language,
      'model_uuid': AppState.instance.modelUUID
    });*/

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
      await ref.push().set({"isUser": true, "message": result.recognizedWords});
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
        drawer: const DrawerWidget(),
        appBar: AppBar(
          leading: (widget.isFromHistory != null && widget.isFromHistory!)
              ? IconButton(
                  onPressed: () async {
                    await tts.stop();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                )
              : null,
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                style: constants.black16W500,
              ),
              const Spacer(),
              Text(
                _toggleValue ? 'On-demand' : 'listening mode',
                style: TextStyle(
                  fontSize: 10,
                  color: _toggleValue ? Colors.green : Colors.grey,
                ),
              ),
              // const Spacer(),
              IconButton(
                onPressed: () async {
                  setState(() {
                    _toggleValue = !_toggleValue; // Toggle the value
                  });
                  print("wewewewewew _toggleValue::$_toggleValue");
                  if (!_toggleValue) {
                    // If switching to Always listening mode
                    // autoSessionId = const Uuid().v4();
                    await tts.stop();
                    await initializeService();

                    /*   periodicTimer = Timer.periodic(
                      const Duration(seconds: 5),
                      (timer) async {
                        // await initializeSpeechToText(autoSessionId!);
                        await initializeService();
                      },
                    );*/
                  } else {
                    listeningActive.value = false; // Stop speech recognition
                    await tts.stop();
                    final service = FlutterBackgroundService();
                    var isRunning = await service.isRunning();
                    if (isRunning) {
                      service.invoke("stopService");
                    }
                    await _speechToText.stop(); // Stop speech recognition
                    if (periodicTimer != null && periodicTimer!.isActive) {
                      periodicTimer?.cancel();
                    }
                  }
                },
                icon: Icon(
                  _toggleValue ? Icons.toggle_on : Icons.toggle_off,
                  color: _toggleValue ? Colors.green : Colors.grey,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.grey[100],
          child: Column(
            children: [
              _toggleValue
                  ? Expanded(
                      child: StreamBuilder(
                        stream: FirebaseDatabase.instance
                            .ref(
                                "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}")
                            .onValue,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            List<ChatBubble> messageList = [];
                            var data = (snapshot.data! as DatabaseEvent)
                                    .snapshot
                                    .value ??
                                {};
                            print("DATAFJLDLFHGLD $data");
                            data = data as Map<dynamic, dynamic>;
                            dataTimer?.cancel();
                            loadingTimer?.cancel();
                            var sortedByKeyMap = Map.fromEntries(
                                data.entries.toList()
                                  ..sort((e1, e2) => e1.key.compareTo(e2.key)));
                            sortedByKeyMap.forEach((key, value) async {
                              if (key != "cart") {
                                final datalast =
                                    Map<String, dynamic>.from(value);
                                print("SORTED MESSAGES ${datalast['message']}");
                                messageList.add(ChatBubble(
                                  text: datalast['message'] ?? '',
                                  isUser: datalast['isUser'],
                                  imageUrl: datalast['mediaUrl'] ?? '',
                                  tableColumnData:
                                      datalast['table_data_columns'],
                                  tableRowData:
                                      datalast['table_data_values'] != null
                                          ? jsonDecode(
                                              datalast['table_data_values'])
                                          : null,
                                  logMessage: datalast['log'] ?? '',
                                ));
                              }
                            });

                            if (widget.isFromHistory != null &&
                                widget.isFromHistory == true &&
                                c == 0) {
                              if (messageList.isNotEmpty &&
                                  !messageList[messageList.length - 1].isUser &&
                                  messageList.length > prevChatLength) {
                                c++;
                              }
                            } else {
                              if (messageList.isNotEmpty &&
                                  !messageList[messageList.length - 1].isUser &&
                                  messageList.length > prevChatLength) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  showLoader.value = false;
                                });
                                tts.speak(
                                    messageList[messageList.length - 1].text);
                              }
                              prevChatLength = messageList.length;
                              if (messageList.isNotEmpty &&
                                  messageList[messageList.length - 1].isUser) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  showLoader.value = true;
                                  tts.stop();
                                });
                              }

                              loadingTimer =
                                  Timer(const Duration(seconds: 4), () {
                                int randomIndex =
                                    Random().nextInt(loaderMsgList.length);
                                if (showLoader.value) {
                                  tts.speak(loaderMsgList[randomIndex]);
                                }
                              });

                              dataTimer =
                                  Timer(const Duration(seconds: 100), () async {
                                print("timerCounter::$timerCounter");
                                if (showLoader.value) {
                                  DatabaseReference ref =
                                      FirebaseDatabase.instance.ref(
                                          "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}");
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    showLoader.value = false;
                                    print("dataNotFoundMsg::$dataNotFoundMsg");
                                  });
                                  await tts.speak(dataNotFoundMsg);
                                }
                              });
                            }

                            return ListView.builder(
                              reverse: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: scrollControllerListView,
                              addAutomaticKeepAlives: true,
                              itemBuilder: (context, index) {
                                if (index < messageList.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: messageList[
                                        messageList.length - 1 - index],
                                  );
                                }
                                return null;
                              },
                              itemCount: messageList.length,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.only(left: 80.0),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ValueListenableBuilder(
                    valueListenable: showLoader,
                    builder: (context, value, _) {
                      if (value) {
                        return SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.asset(
                                'assets/images/response_bubble.gif'));
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              _toggleValue
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: bottomBar(),
                    )
                  : const SizedBox(),
              /* _toggleValue
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ValueListenableBuilder(
                            valueListenable: listeningActive,
                            builder: (context, value, _) {
                              return AvatarGlow(
                                animate: value,
                                glowColor: Colors.purple,
                                child: FloatingActionButton(
                                  onPressed:
                                      // If not yet listening for speech start, otherwise stop
                                      !value ? _startListening : _stopListening,
                                  tooltip: 'Listen',
                                  child:
                                      Icon(!value ? Icons.mic_off : Icons.mic),
                                ),
                              );
                            },
                          ), // your widget would go here
                        ),
                      ))
                  : const Padding(
                      padding: EdgeInsets.all(20),
                      child: SizedBox(),
                    )*/
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      // width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          // SpeechToTextWidget(updateSpeech: updateChatControllerForSpeech, localeId: "en-US"),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder(
                valueListenable: listeningActive,
                builder: (context, value, _) {
                  return AvatarGlow(
                    animate: value,
                    glowColor: Colors.purple,
                    child: FloatingActionButton(
                      onPressed: !value ? _startListening : _stopListening,
                      tooltip: 'Listen',
                      child: Icon(!value ? Icons.mic_off : Icons.mic),
                    ),
                  );
                },
              ),
            ),
          ),
          CameraWidget(saveCapturedPhoto: saveCapturedPhoto),
          Expanded(
            child: Stack(
              children: [
                if (capturedPhoto != null)
                  Positioned(
                    left: 0,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.file(capturedPhoto!, fit: BoxFit.cover),
                    ),
                  ),
                Container(
                  margin: EdgeInsets.only(left: capturedPhoto != null ? 60 : 0),
                  child: TextFormField(
                    controller: chatController,
                    maxLines: 10,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) {
                      if (capturedPhoto != null) {}
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF4BA164),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF4BA164),
                        ),
                        onPressed: () async {
                          addUserUploadedImageToChat();
                          addUserMessageToChat(chatController.text);
                          print("capturedPhoto::$capturedPhoto");
                          if (chatController.text.isEmpty) {
                            Fluttertoast.showToast(
                                msg: "Please enter your question.");
                          } else {
                            String? imageUrl = '';
                            if (capturedPhoto != null) {
                              imageUrl = await uploadMedia(
                                  context, capturedPhoto!.path);
                            }
                            await insertDataIntoDb(
                                imageUrl, chatController.text);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          /*Expanded(
            child: Stack(
              children: [
                if (capturedPhoto != null)
                  Positioned(
                    left: 0,
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Image.file(capturedPhoto!, fit: BoxFit.cover),
                    ),
                  ),
                Container(
                  margin: EdgeInsets.only(left: capturedPhoto != null ? 60 : 0),
                  child: TextFormField(
                    controller: chatController,
                    maxLines: 10,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (value) {
                      if (capturedPhoto != null) {}
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color(0xFF4BA164),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF4BA164),
                        ),
                        onPressed: () async {
                          print("capturedPhoto::${capturedPhoto}");

                          if(chatController.text.isEmpty){
                            Fluttertoast.showToast(msg: "Please enter your question.");
                          }
                          chatController.clear();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }

  updateChatControllerForSpeech(String text) {
    chatController.text = text;
    // setState(() {});
  }

  saveCapturedPhoto(XFile photo) {
    capturedPhoto = File(photo.path);
    setState(() {});
    /*if (capturedPhoto != null) {
      updateChatControllerWithPhotoName(photo.name);
    }*/
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
    print("userId::${AppState.instance.userId}");
    print("projectId::${constants.projectId}");
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "${constants.keyspace}/${constants.projectId}/${AppState.instance.userId}/${widget.sessionId}");

    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    print("wewewew DateTime before push:: $formattedDate");
    await ref.child(timeStamp).set({
      "isUser": true,
      "message": text,
      "mediaUrl": '',
      "language": language,
      "model_uuid": AppState.instance.modelUUID,
      "mode": AppState.instance.mode
    });

    DateTime nowTime = DateTime.now();
    String formattedDateTime =
        DateFormat('kk:mm:ss \n EEE d MMM').format(nowTime);
    print("wewewew DateTime after push:: $formattedDateTime");

    chatController.clear();
    capturedPhoto = null;
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
    print(("startListeningToHello: starting listening"));
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyD4kQrxxhyhqQwRjhnKRVJPgpT9jkuadUo',
      appId: '1:1062998944432:ios:597dab286cd6fc12f22975',
      messagingSenderId: '1062998944432',
      projectId: 'apwrims---chatbot',
      storageBucket: 'apwrims---chatbot.appspot.com',
      iosBundleId: 'com.vassar.apwrimschatbot',
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
    print(
        "wewewewewew AppState.instance.triggeredWord ::  ${AppState.instance.triggeredWord}");
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

/*Future<void> initializeSpeechToText(String sessionId) async {
    print(("startListeningToHello: starting listening"));

    bool available = await _speechToText.initialize(
      onStatus: (status) async {
        print('Status: $status');
      },
      onError: (error) async {
        print('Error: $error');
      },
    );
    if (available) {
      await _startListeningForAutoMode();
    }
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
    iosBundleId: 'com.vassar.apwrimschatbot',
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
  print(
      "wewewewewew AppState.instance.triggeredWord ::  ${AppState.instance.triggeredWord}");
  print("wewewewewew session $sessionId");
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
  DatabaseReference ref = FirebaseDatabase.instance.ref(
      "CHAT_BOT_CHANGELOG/${constants.projectId}/${AppState.instance.userId}/${sessionId}");
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
            "isUser": true,
            "event_name": 'CONTINUOUS_LISTEN_MODE',
            "trigger_word": '${AppState.instance.triggeredWord}'
          });
          print("111111-pushed");
          /* await ref.push().set({
            "isUser": false,
            "event_name": 'CONTINUOUS_LISTEN_MODE',
            "changelog": 'No Change in $AppState.instance.triggeredWord Data'
          });*/
          Future.delayed(const Duration(seconds: 2), () async {
            print(
                "wewewewewe AppState.instance.triggeredWord after completion::${AppState.instance.triggeredWord}");
            await ref.orderByKey().limitToLast(1).once().then((event) async {
              DataSnapshot snapshot = event.snapshot;
              print("values::${snapshot.value}");
              if (snapshot.value != null) {
                dynamic values = snapshot.value;
                values.forEach((key, value) async {
                  if (!value['isUser']) {
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

/*Future<String> startListenings(String sessionId) async {
  int i = 0;
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("CHAT_BOT_CHANGELOG/${constants.projectId}/${AppState.instance.userId}/${sessionId}");
  SpeechRecognitionResult result;

  await speechToText.listen(
    partialResults: false,
    onResult: (data) async {
      result = data;
      print("111111-input::${result.recognizedWords}");

      if (result.recognizedWords.isNotEmpty &&
          result.recognizedWords.toLowerCase().contains('rainfall')) {
        await speechToText.stop();
        i++;
        AppState.instance.triggeredWord = "RAINFALL";
        await tts.speak('Would you like to know the rainfall data');
      }
      if (result.recognizedWords.isNotEmpty &&
          result.recognizedWords.toLowerCase().contains('reservoir')) {
        await speechToText.stop();
        i++;
        AppState.instance.triggeredWord = "RESERVOIR";
        await tts.speak('Would you like to know reservoir data');
      }
      if (result.recognizedWords.isNotEmpty &&
          result.recognizedWords.toLowerCase().contains('groundwater')) {
        await speechToText.stop();
        i++;
        AppState.instance.triggeredWord = "GROUNDWATER";
        await tts.speak('Would you like to know groundwater data');
      }
      if (result.recognizedWords.isNotEmpty &&
          result.recognizedWords.toLowerCase().contains('soil moisture')) {
        await speechToText.stop();
        i++;
        AppState.instance.triggeredWord = "SOIL_MOISTURE";
        await tts.speak('Would you like to know soil moisture data');
      }

      */ /* Future.delayed(const Duration(seconds: 10),() async {
        await startListeningToYes(sessionId, AppState.instance.triggeredWord);
      });*/ /*
*/ /*
      if (result.recognizedWords.toLowerCase() == 'yes') {
        await ref.push().set({
          "isUser": true,
          "event_name": 'CONTINUOUS_LISTEN_MODE',
          "trigger_word": AppState.instance.triggeredWord
        });

        await ref.push().set({
          "isUser": false,
          "event_name": 'CONTINUOUS_LISTEN_MODE',
          "changelog": 'No Change in $AppState.instance.triggeredWord Data'
        });
        await ref.orderByKey().limitToLast(1).once().then((event) async {
          DataSnapshot snapshot = event.snapshot;
          print("values::${snapshot.value}");
          if (snapshot.value != null) {
            dynamic values = snapshot.value;
            values.forEach((key, value) async {
              if (value['isUser'] == false) {
                String responseMessage = value['changelog'] ?? '';
                await tts.speak(responseMessage);
              }
            });
          }
        });
        // speechStatus.value = SpeechStatus.listening;
        await speechToText.stop();
        Future.delayed(const Duration(seconds: 5), () async {
          await startListenings(sessionId);
        });
      }*/ /*
    },
  );
  return AppState.instance.triggeredWord;
}

Future<void> startListeningToYes(String sessionId, String word) async {
  print("startListeningToYes");
  print("wewewewewew trigger word :: ${AppState.instance.triggeredWord}");
  await speechToText.stop();
  print("wewewewewew speechToText.isListening:: ${speechToText.isListening}");
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("CHAT_BOT_CHANGELOG/${constants.projectId}/${AppState.instance.userId}/${sessionId}");
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
            "isUser": true,
            "event_name": 'CONTINUOUS_LISTEN_MODE',
            "trigger_word": '${AppState.instance.triggeredWord}'
          });
          print("111111-pushed}");
          */ /* await ref.push().set({
            "isUser": false,
            "event_name": 'CONTINUOUS_LISTEN_MODE',
            "changelog": 'No Change in $AppState.instance.triggeredWord Data'
          });*/ /*
          Future.delayed(const Duration(seconds: 2), () async {
            print(
                "wewewewewe AppState.instance.triggeredWord after completion::${AppState.instance.triggeredWord}");
            await ref.orderByKey().limitToLast(1).once().then((event) async {
              DataSnapshot snapshot = event.snapshot;
              print("values::${snapshot.value}");
              if (snapshot.value != null) {
                dynamic values = snapshot.value;
                values.forEach((key, value) async {
                  if (value['isUser'] == false) {
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
}*/
