import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:gka/services/api_provider.dart';
import '../utils/common_constants.dart' as constants;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat_bubble.dart';
import 'package:gka/text_to_speech.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'dart:developer' as developer;
import 'camera_screen.dart';
import 'message_bubble.dart';
import 'utils/network_utils.dart';

class ChatWindow extends StatefulWidget {
  const ChatWindow(
      {Key? key,
        required this.isFirstTime,
        required this.finishSession,
        required this.sessionId})
      : super(key: key);

  final bool isFirstTime;
  final Function(bool finishSession) finishSession;
  final String sessionId;

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  var scrollControllerListView = ScrollController();
  int prevChatLength = 0;
  TextToSpeech tts = TextToSpeech();
  int responseCount = 1;
  String sessionId = "";
  String queryString = "";
  TextEditingController chatController = TextEditingController();
  bool speechToTextOn = false;
  File? capturedPhoto;
  List<MessageBubble> chatMessages = [];
  TextToSpeechService? textToSpeechService;
  MessageBubble? textToSpeechMessageBubble;

  // Create a transparent overlay to cover the whole screen
  OverlayEntry? overlayEntry;

  // final OnDeviceTranslator translator = GoogleMlKit.nlp.onDeviceTranslator(sourceLanguage: TranslateLanguage.english, targetLanguage: TranslateLanguage.telugu);

  @override
  void initState() {
    super.initState();
    _initSpeech();
    tts.setRate(1);
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
    print("Available languages ${await tts.getLanguages()}");
    await tts.setLanguage("en-US");
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
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
    try {
      await _speechToText.listen(
          onSoundLevelChange: onSoundLevelChange,
          /*localeId: selectedLocale.localeId,*/
          partialResults: false,
          onResult: _onSpeechResult,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 15),
          cancelOnError: true);
    } catch (e) {
      print('EXCEPTIONKJSKFJK An exception occurred: $e');
    }

    print("_onSpeechResult_startListening aferfdf ${_speechToText.lastStatus}");
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
    /*setState(() {});*/
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    print("_onSpeechResult ${result.recognizedWords}");
    DatabaseReference ref =
    FirebaseDatabase.instance.ref("CHAT_BOT_WEATHER/${widget.sessionId}");

    // TransliterationResponse? response = await Transliteration.transliterate(result.recognizedWords, Languages.TELUGU);
    // final translatedText =response?.transliterationSuggestions[0].toString();
    // print("translated::$translatedText");
    await ref.push().set({"isUser": true, "message": result.recognizedWords});
    // await ref.push().set({"isUser": false, "message": "Response ${responseCount++}"});
    /* String responseMsg = "Cheppandi";
    TransliterationResponse? _response = await Transliteration.transliterate(responseMsg, Languages.TELUGU);
    final translatedResponse = _response?.transliterationSuggestions[0].toString();
    print("translated::$translatedText");
    await ref.push().set({"isUser": true, "message": translatedText});
    await ref.push().set({"isUser": false, "message": translatedResponse});*/
    bool active = _speechToText.isListening;
    listeningActive.value = active;
    // tts.speak(translatedResponse!);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          color: Colors.grey[100],
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance.ref("CHAT_BOT_WEATHER/${widget.sessionId}").onValue,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      List<ChatBubble> messageList = [];
                      var data =
                          (snapshot.data! as DatabaseEvent).snapshot.value ?? {};
                      print("DATAFJLDLFHGLD $data");
                      data = data as Map<dynamic, dynamic>;
                      var sortedByKeyMap = Map.fromEntries(data.entries.toList()
                        ..sort((e1, e2) => e1.key.compareTo(e2.key)));
                      sortedByKeyMap.forEach((key, value) {
                        if (key != "cart") {
                          final datalast = Map<String, dynamic>.from(value);
                          print("SORTED MESSAGES ${datalast['message']}");
                          messageList.add(ChatBubble(
                              text: datalast['message'],
                              isUser: datalast['isUser']));
                        }
                      });
                      //messageList.reversed;
                      if (messageList.isNotEmpty &&
                          !messageList[messageList.length - 1].isUser &&
                          messageList.length > prevChatLength) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showLoader.value = false;
                        });
                        tts.speak(messageList[messageList.length - 1].text);
                      }
                      prevChatLength = messageList.length;
                      if (messageList.isNotEmpty &&
                          messageList[messageList.length - 1].isUser) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showLoader.value = true;
                        });

                        Timer(const Duration(seconds: 5), () {
                          if (showLoader.value) {
                            tts.speak("Please wait, while we are fetching ${messageList[messageList.length - 1].text}");
                          }
                        });
                          // tts.speak("Please wait,while we are fetching ${messageList[messageList.length - 1].text}");
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
                              child: messageList[messageList.length - 1 - index],
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
                            child:
                            Image.asset('assets/images/response_bubble.gif'));
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
             /* Padding(
                padding: const EdgeInsets.all(20),
                child: bottomBar(),
              )*/
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
                          print("capturedPhoto::$capturedPhoto");
                          if(chatController.text.isEmpty){
                            Fluttertoast.showToast(msg: "Please enter your question.");
                          }
                          submitFarmerPhoto(context,capturedPhoto!.path);
                          chatController.clear();
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
    if (capturedPhoto != null) {
      updateChatControllerWithPhotoName(photo.name);
    }
  }

  updateChatControllerWithPhotoName(String name) {
    chatController.text = name;
    setState(() {});
  }

  createQueryString() {
    queryString = chatController.text;
    chatController.clear();
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
    chatController.clear();
    setState(() {});
  }

  Future uploadImage() async {
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
          name: 'AgriBot',
          error: e.toString(),
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Please check your network connection, no internet available');
    }
  }

  initAndPlayText() async {
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

  Future<bool?> submitFarmerPhoto(BuildContext context, String imagePath) async {
      if (await networkUtils.hasActiveInternet()) {
        try {
          Map<String, String> params = {};
            params = {
              'appUUID': constants.appUUID,
              'farmerUUID': '48984q',
              'src': 'MOBILE_APP',
              // 'imageLabel': '${AppState.instance.farmerUUID}_$farmerName.png',
              'imageLocType': 'VILLAGE',
          };
          bool result = await ApiProvider.instance.submitFarmerImage(params, imagePath);
          return result;
        } catch (e) {
          Fluttertoast.showToast(
              msg: constants.genericErrorMsg, toastLength: Toast.LENGTH_LONG);
        }
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: constants.noNetworkAvailability, toastLength: Toast.LENGTH_LONG);
      }
      setState(() {
      });
      return null;
    }
}