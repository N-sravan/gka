import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:gka/utils/secure_storage_util.dart';
import 'package:gka/text_to_speech.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gka/chat/view/drawer_widget.dart';
import 'package:gka/services/api_provider.dart';
import 'package:gka/utils/app_state.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io' as platform;
import '../utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:developer' as developer;
import 'camera_screen.dart';
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

class _ChatWindowState extends State<ChatWindow> {
  var scrollControllerListView = ScrollController();

  // final SupabaseClient supabase = Supabase.instance.client;
  int start = 0;
  int end = 0;
  bool hasSpoken = false;
  String? _newVoiceText;
  int prevChatLength = 0;
  int prevChatLengthHistory = 0;
  int c = 0;
  int responseCount = 1;
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
  final List<Map<String, dynamic>> _messages = [];
  String url = '';
  late final channel;

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
    AppState.instance.language = 'english';
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
    _initWsConnection();
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

    print("Available languages ${await tts.getLanguages}");
    await tts.setLanguage(langId);
    await tts.setSpeechRate(0.5);
    await tts.setVoice(currentVoice);
    print("language::${AppState.instance.language.toLowerCase()}");
    print("lang Id::$langId");
    print("user id::${AppState.instance.userId}");
    print("session id::${AppState.instance.sessionId}");
  }

  _initWsConnection() async {
    await _initDeviceId();
    try {
      channel = IOWebSocketChannel.connect(url);
      channel.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data);
            final result = decoded['message'];
            final isUser = decoded['is_user'];
            print("Received result: $result");

            setState(() {
              _messages.add({
                'text': result,
                'is_user': isUser,
              });
              showLoader.value = false;
            });
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

  @override
  Widget build(BuildContext context) {
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
          sessionId: widget.sessionId!,
        ),
        appBar: AppBar(
          titleSpacing: 2,
          title: Row(
            children: [
              Image.asset(
                'assets/images/apaims_logo.png',
                height: 32, // Adjust height as needed
              ),
              const SizedBox(width: 8),
              const Text(
                'APAIMS Chatbot',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: showLoader,
                builder: (context, isLoading, _) {
                  return ListView.builder(
                    controller: scrollControllerListView,
                    reverse: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (_, index) {
                      if (isLoading && index == 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showLoader.value = true;
                          tts.stop();
                        });
                        return const SizedBox();
                      }

                      final adjustedIndex = isLoading
                          ? _messages.length - index
                          : _messages.length - 1 - index;

                      if (adjustedIndex < 0 ||
                          adjustedIndex >= _messages.length) {
                        return const SizedBox();
                      }

                      final msg = _messages[adjustedIndex];

                      // SPEAK LOGIC (for each new bot message)
                      if (_messages.isNotEmpty &&
                          !_messages.last['is_user'] &&
                          _messages.last['text'].toString().isNotEmpty &&
                          _messages.length > prevChatLength) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showLoader.value = false;
                          _speakMessage(_messages.last['text']);
                        });
                      }

                      // STOP if user message came in
                      if (_messages.isNotEmpty && _messages.last['is_user']) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showLoader.value = true;
                          tts.stop();
                        });
                      }

                      prevChatLength = _messages.length;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ChatBubble(
                          text: msg['text'] ?? '',
                          isUser: msg['is_user'],
                          imageUrl: msg['image_url'] ?? '',
                          tableColumnData: msg['sql_df_columns'],
                          tableRowData: msg['sql_df_values'] != null
                              ? jsonDecode(msg['sql_df_values'])
                              : null,
                          logMessage: msg['log'] ?? '',
                          hasErrorLog: false,
                          timestampMapping: {},
                          chainOfThoughts: Map<String, String>.from(
                            msg['chain_of_thought'] ?? {},
                          ),
                          followUpQuestions:
                              (msg['follow_up_questions'] as List<dynamic>?)
                                      ?.map((e) => e.toString())
                                      .toList() ??
                                  [],
                          token: msg['token'] ?? '',
                          isMapView: false,
                          expandChainOfThought:
                              adjustedIndex == _messages.length - 1,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ValueListenableBuilder(
                  valueListenable: showLoader,
                  builder: (context, value, _) {
                    if (value) {
                      return LoadingAnimationWidget.waveDots(
                          color: Colors.blue, size: 40);
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: bottomBar(),
            )
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
            // prefixIcon: _speechButton(),
            suffixIcon: _sendButton(),
          ),
        ),
        /* Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _dropdownInsideField(!isllmDropdown)),
            const SizedBox(width: 8), // Spacing between dropdowns
            Expanded(child: _dropdownInsideField(isllmDropdown)),
          ],
        ),*/
      ],
    );
  }

  Widget bottomBar() {
    return Container(
      padding: const EdgeInsets.all(4),
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
        /* capturedPhoto == null
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
              ),*/
        ValueListenableBuilder(
          valueListenable: showLoader,
          builder: (context, value, _) {
            return IconButton(
                icon: Icon(Icons.send,
                    color: showLoader.value ? Colors.grey : Colors.blue),
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
                          _sendMessage(chatController.text);
                        }
                      });
          },
        ),
      ],
    );
  }

  void updateChatControllerForSpeech(String text) {
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

  Future<void> _initDeviceId() async {
    String deviceId = const Uuid().v4();

    // url = 'ws://192.168.18.40:8000/ws/chat/$deviceId';
    url = 'wss://apaims2.0.vassarlabs.com/chatbot/ws/chat/$deviceId';
    print("12345 Generated Device ID: $deviceId");
    print("12345 Web socket URL: $url");
  }

  void _sendMessage(String message) {
    String formattedId = formatSession();
    final messageJson = jsonEncode({
      'message': message,
      'user_id': AppState.instance.userId,
      'session_id': formattedId,
      'is_user': true,
    });

    print("12345 Input data::$messageJson");

    channel.sink.add(messageJson);

    setState(() {
      _messages.add({
        'text': message,
        'is_user': true,
      });
      chatController.clear();
      showLoader.value = true;
    });
  }

  void _speakLastBotMessage() {
    if (hasSpoken) return;

    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i]['is_user'] == false) {
        String message = _messages[i]['text'] ?? '';
        if (message.isNotEmpty) {
          tts.speak(message);
          print("last message: $message");
          hasSpoken = true;
        }
        break;
      }
    }
  }

  String formatSession() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(AppState.instance.sessionId));
    // final formatted = DateFormat('MMM dd,HH:mm:ss').format(dateTime);
    final formatted = DateFormat('MMM dd-HH_mm_ss').format(dateTime);
    return 'Session $formatted';
  }
}
