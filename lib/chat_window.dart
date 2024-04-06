import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gka/chat/view/drawer_widget.dart';
import 'package:gka/services/api_provider.dart';
import 'package:gka/utils/app_state.dart';
import 'package:transliteration/response/transliteration_response.dart';
import 'package:transliteration/transliteration.dart';
import 'package:uuid/parsing.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';
import '../utils/common_constants.dart' as constants;
import 'package:flutter/cupertino.dart';
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

class ChatWindow extends StatefulWidget {
  const ChatWindow(
      {Key? key,
      required this.isFirstTime,
      required this.finishSession,
      required this.sessionId,
        this.isFromHistory,
      })
      : super(key: key);

  final bool isFirstTime;
  final Function(bool finishSession) finishSession;
  final String sessionId;
  final bool? isFromHistory;

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  var scrollControllerListView = ScrollController();
  int prevChatLength = 0;

  // TextToSpeech tts = TextToSpeech();
  FlutterTts tts = FlutterTts();
  int responseCount = 1;
  String sessionId = "";
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

  bool _toggleValue = false;
  OverlayEntry? overlayEntry;
  late Timer periodicTimer;
  Timer? dataTimer;
  Timer? loadingTimer;
  String autoSessionId = '';
  int c=0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    // tts.setRate(1);
  }

  @override
  void dispose() {
    // Dispose of the timer when the widget is removed
    // periodicTimer.cancel();
    dataTimer?.cancel();
    loadingTimer?.cancel();
    showLoader.value = false;
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

    //print("Available voices ${await tts.getVoice()}");
    print("Available languages ${await tts.getLanguages}");
    AppState.instance.isOriyaSelected
        ? await tts.setLanguage("or-IN")
        : await tts.setLanguage("en-US");
  }

  /// Each time to start a speech recognition session
  _startListening() async {
    var locales = await _speechToText.locales();
    for (int i = 0; i < locales.length; i++) {
      print("LOCALESDSD $i   ${locales[i].name}");
    }

    String langId = '';
    AppState.instance.isOriyaSelected ? langId = 'or-IN' : langId = 'en-US';
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
          localeId: langId,
          partialResults: false,
          onResult: _onSpeechResult,
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
          onResult: _onSpeechResultForAutoMode,
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

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    bool active = _speechToText.isListening;
    listeningActive.value = active;
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    print("_onSpeechResult ${result.recognizedWords}");
    await updateChatControllerForSpeech(result.recognizedWords);
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "CHAT_BOT_ONDEMAND_QUERY_DATA/${constants.odishaUUID}/${AppState.instance.userUUID}/${widget.sessionId}");
    !_toggleValue ? llmType = "internal" : llmType = "external";
    print("llmType::${llmType}");

    TransliterationResponse? response = await Transliteration.transliterate(
        result.recognizedWords, Languages.ORIYA);
    final translatedText = response?.transliterationSuggestions[0].toString();
    print("translated::$translatedText");
    AppState.instance.isOriyaSelected
        ? await ref.push().set({
            "isUser": true,
            "message": translatedText,
            "mediaUrl": '',
            "llm_type": llmType,
            'language': 'odia'
          })
        : await ref.push().set({
            "isUser": true,
            "message": result.recognizedWords,
            "mediaUrl": '',
            "llm_type": llmType,
            'language': 'english'
          });

    bool active = _speechToText.isListening;
    listeningActive.value = active;
  }

  Future<void> _onSpeechResultForAutoMode(
      SpeechRecognitionResult result) async {
    print("_onSpeechResultForAutoMode ${result.recognizedWords}");
    print("_onSpeechResultForAutoMode autoSessionId ${autoSessionId}");
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "CHAT_BOT_ONDEMAND_QUERY_DATA/${constants.odishaUUID}/${AppState.instance.userUUID}/${autoSessionId}");

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
      await ref.push().set({"isUser": false, "message": "response"});
    }

    bool active = _speechToText.isListening;
    listeningActive.value = active;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? result = await showSessionDialog();
        if (result != null && result) {
          tts.stop();
          _speechToText.stop();
          // periodicTimer.cancel();
          Navigator.pop(context);
        }
        return false;
      },
      child: Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GoWater Bot',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Spacer(), // Add spacing between title and toggle
              Text(
                _toggleValue ? 'External LLM' : 'Internal LLM',
                style: TextStyle(
                  fontSize: 12,
                  color: _toggleValue ? Colors.black : Colors.green,
                ),
              ),

              IconButton(
                onPressed: () async {
                  setState(() {
                    _toggleValue = !_toggleValue; // Toggle the value
                  });
                  print("wewewewewew _toggleValue::$_toggleValue");
                  /* if (!_toggleValue) {
                    autoSessionId= Uuid().v4();
                    periodicTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
                      await initializeSpeechToText(autoSessionId);
                    });
                  } else {
                    await _speechToText.stop();
                    await tts.stop();
                    periodicTimer.cancel();
                  }*/
                },
                icon: Icon(
                  !_toggleValue ? Icons.toggle_on : Icons.toggle_off,
                  color: !_toggleValue ? Colors.green : Colors.black,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: Colors.grey[100],
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref(
                          "CHAT_BOT_ONDEMAND_QUERY_DATA/${constants.odishaUUID}/${AppState.instance.userUUID}/${widget.sessionId}")
                      .onValue,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      List<ChatBubble> messageList = [];
                      var data =
                          (snapshot.data! as DatabaseEvent).snapshot.value ??
                              {};
                      print("DATAFJLDLFHGLD $data");
                      data = data as Map<dynamic, dynamic>;
                      dataTimer?.cancel();
                      loadingTimer?.cancel();
                      var sortedByKeyMap = Map.fromEntries(data.entries.toList()
                        ..sort((e1, e2) => e1.key.compareTo(e2.key)));
                      sortedByKeyMap.forEach((key, value) {
                        if (key != "cart") {
                          final datalast = Map<String, dynamic>.from(value);
                          print("SORTED MESSAGES ${datalast['message']}");
                          print("Session Id ${widget.sessionId}");
                          messageList.add(ChatBubble(
                            text: datalast['message'],
                            isUser: datalast['isUser'],
                            imageUrl: datalast['mediaUrl'],
                            logMessage: datalast['log'] ?? '',
                          ));
                        }
                      });
                      if (widget.isFromHistory != null &&
                          widget.isFromHistory == true &&
                          c == 0) {
                        //messageList.reversed;
                        if (messageList.isNotEmpty &&
                            !messageList[messageList.length - 1].isUser &&
                            messageList.length > prevChatLength) {
                          c++;
                          /*  WidgetsBinding.instance.addPostFrameCallback((_) {
                            showLoader.value = false;
                          });
                          tts.speak(messageList[messageList.length - 1].text);*/
                        }
                      } else {
                        if (messageList.isNotEmpty &&
                            !messageList[messageList.length - 1].isUser &&
                            messageList.length > prevChatLength) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showLoader.value = false;
                          });
                          tts.speak(messageList[messageList.length - 1].text);
                        }
                      }
                      prevChatLength = messageList.length;
                      if (messageList.isNotEmpty &&
                          messageList[messageList.length - 1].isUser) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showLoader.value = true;
                        });

                        loadingTimer = Timer(const Duration(seconds: 4), () {
                          int randomIndex =
                              Random().nextInt(loaderMsgList.length);
                          if (showLoader.value) {
                            tts.speak(loaderMsgList[randomIndex]);
                          }
                        });

                        dataTimer = Timer(const Duration(seconds: 15), () {
                          print("timerCounter::$timerCounter");
                          if (showLoader.value) {
                            /* messageList.add(ChatBubble(
                              text: "Data Not Found",
                              isUser: false,
                              imageUrl: "",
                              logMessage: '',
                            ));*/
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showLoader.value = false;
                            });
                            tts.speak("Data Not found");
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
                              child:
                                  messageList[messageList.length - 1 - index],
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
              ),
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
              Padding(
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
                          child: Icon(!value ? Icons.mic_off : Icons.mic),
                        ),
                      );
                    },
                  ), // your widget would go here
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.all(20),
                child: bottomBar(),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: [
          /*SpeechToTextWidget(updateSpeech: updateChatControllerForSpeech, localeId: "en-US"),*/
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
                              imageUrl = await submitImage(
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
    setState(() {});
  }

  saveCapturedPhoto(XFile photo) {
    capturedPhoto = File(photo.path);
    setState(() {});
    /*if (capturedPhoto != null) {
      updateChatControllerWithPhotoName(photo.name);
    }*/
  }

  updateChatControllerWithPhotoName(String name) {
    chatController.text = name;
    setState(() {});
  }

  /* createQueryString() {
    queryString = chatController.text;
    chatController.clear();
    setState(() {});
  }*/

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

  /*Future uploadImage() async {
    MessageBubble messageBubble = MessageBubble(
      user: false,
      textToSpeechEnabled: false,
      isResponseLoading: true,
      isTextToSpeechRunning: false,
    );
    chatMessages.add(messageBubble);
    setState(() {});
    if (await networkUtils.hasActiveInternet()) {
      try {
        Map<String, String> requestMap = {
          "session_id": sessionId,
        };
        if (capturedPhoto != null) {
          File? compressedFile;
          final bytes = capturedPhoto!.readAsBytesSync().lengthInBytes;
          final kb = bytes / 1024;
          final imageSize = kb / 1024;
          if (imageSize > 1) {
            compressedFile = await FlutterNativeImage.compressImage(
              capturedPhoto!.path,
              quality: 50,
            );
          } else {
            compressedFile = capturedPhoto;
          }
          // dynamic response = await imageUpload(compressedFile!, requestMap);
          String responseMessage = "Hello";
          // if (response.containsKey("pest_name")) {
          //   responseMessage = response["pest_name"];
          // } else if (response.containsKey("query")) {
          //   responseMessage = response["query"];
          // }
          MessageBubble messageBubble = chatMessages.last;
          messageBubble.message = responseMessage;
          messageBubble.isResponseLoading = false;
          messageBubble.textToSpeechEnabled = true;
          capturedPhoto = null;
          textToSpeechMessageBubble = messageBubble;
          setState(() {});
          initAndPlayText();
        }
      } catch (e) {
        developer.log(
          'Upload Image',
          name: 'GoWater Bot',
          error: e.toString(),
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Please check your network connection, no internet available');
    }
  }*/

  /*initAndPlayText() async {
    int? playStatus;
    String language = "en-US";
    TextToSpeechService.instance
        .initTts(textToSpeechMessageBubble!.message!, language);
    textToSpeechMessageBubble!.isTextToSpeechRunning = true;
    setState(() {});
    playStatus = await TextToSpeechService.instance.speak();
    if (playStatus != null && playStatus == 1) {
      textToSpeechMessageBubble!.isTextToSpeechRunning = false;
      setState(() {});
    }
  }*/

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

  Future<String?> submitImage(BuildContext context, String imagePath) async {
    if (await networkUtils.hasActiveInternet()) {
      try {
        Map<String, String> params = {};
        params = {"bucket_name": "crop_bucket"};
        String? url = await ApiProvider.instance.submitImage(params, imagePath);
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
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        "CHAT_BOT_ONDEMAND_QUERY_DATA/${constants.odishaUUID}/${AppState.instance.userUUID}/${widget.sessionId}");
    !_toggleValue ? llmType = "internal" : llmType = "external";
    await ref.push().set({
      "isUser": true,
      "message": text,
      "mediaUrl": imageUrl,
      "llm_type": llmType
    });
    chatController.clear();
    capturedPhoto = null;
    setState(() {});
  }

  Future<void> initializeSpeechToText(String sessionId) async {
    print(("startListeningToHello: starting listening"));

    bool available = await speechToText.initialize(
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
  }
}
