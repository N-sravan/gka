import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart' as fs;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../chat_bubble.dart';
import '/utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import 'drawer_widget.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    this.isFromHistory,
    this.sessionId,
  });

  final bool? isFromHistory;
  final String? sessionId;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  var scrollControllerListView = ScrollController();
  StreamController<Uint8List> streamController = StreamController<Uint8List>();
  final SpeechToText _speechToText = SpeechToText();
  ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  late ChatViewModel viewModel;
  bool _speechEnabled = false;
  String langId = '';
  String language = '';
  FlutterTts tts = FlutterTts();
  final _audioRecorder = fs.FlutterSoundRecorder();
  late StreamController<Uint8List> _audioStreamController;
  WebSocketChannel? channel;
  bool _isRecording = false;
  Timer? _inactivityTimer;
  String? _lastRecognizedText;

  Map<String, String> currentVoice = {
    "name": "en-us-x-iom-local",
    "locale": "en-US"
  };

  @override
  void initState() {
    super.initState();
    AppState.instance.isEnglish = true;
    AppState.instance.language = 'english';
    langId = 'en-IN';
    _initRecorder();
    _initSpeech();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.initWebsocketConnection(context);
      if (widget.isFromHistory != null && widget.isFromHistory == true) {
        await viewModel.getMessageHistoryForSession(widget.sessionId!, context);
      }
    });
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) {
        print("Speech recognition error: $error");
        _stopListening();
      },
      onStatus: (status) {
        print("Speech recognition status: $status");
      },
      debugLogging: true, // Enables detailed logging
    );

    if (_speechEnabled) {
      // Retrieve the list of available locales
      var locales = await _speechToText.locales();
      // Set the desired locale, e.g., 'en-IN' for English (India)
      // Configure Text-to-Speech settings
      await tts.setLanguage(langId);
      await tts.setSpeechRate(0.5);
      await tts.setVoice(currentVoice);
    } else {
      print("Speech recognition is not available on this device.");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _audioRecorder.closeRecorder();
    _audioStreamController.close();
    _isRecording = false;
    tts.stop();
    showLoader.value = false;
    viewModel.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        return Scaffold(
          drawer: (widget.isFromHistory != null && widget.isFromHistory == true)
              ? null
              : const DrawerWidget(),
          appBar: AppBar(
            leading:
                (widget.isFromHistory != null && widget.isFromHistory == true)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      )
                    : null,
            titleSpacing: 2,
            title: Row(
              children: [
                Image.asset(
                  'assets/images/apaims_logo.png',
                  height: 32,
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
          body: model.isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: constants.indicator,
                )
              : Column(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: viewModel.showLoader,
                        builder: (context, isLoading, _) {
                          return ListView.builder(
                            controller: scrollControllerListView,
                            reverse: true,
                            padding: const EdgeInsets.all(10),
                            itemCount:
                                viewModel.messages.length + (isLoading ? 1 : 0),
                            itemBuilder: (_, index) {
                              if (isLoading && index == 0) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  viewModel.showLoader.value = true;
                                });
                                return const SizedBox();
                              }

                              final adjustedIndex = isLoading
                                  ? viewModel.messages.length - index
                                  : viewModel.messages.length - 1 - index;

                              if (adjustedIndex < 0 ||
                                  adjustedIndex >= viewModel.messages.length) {
                                return const SizedBox();
                              }

                              final msg = viewModel.messages[adjustedIndex];

                              // SPEAK LOGIC (for each new bot message)
                              if (viewModel.messages.isNotEmpty &&
                                  !viewModel.messages.last['is_user'] &&
                                  viewModel.messages.last['text']
                                      .toString()
                                      .isNotEmpty &&
                                  viewModel.messages.length >
                                      viewModel.prevChatLength) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  showLoader.value = false;
                                  _speakMessage(
                                      viewModel.messages.last['text']);
                                });
                              }

                              // STOP if user message came in
                              if (viewModel.messages.isNotEmpty &&
                                  viewModel.messages.last['is_user']) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  viewModel.showLoader.value = true;
                                  // tts.stop();
                                });
                              }

                              viewModel.prevChatLength =
                                  viewModel.messages.length;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: ChatBubble(
                                  timestamp: msg['timestamp'] ?? '',
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
                                  followUpQuestions: (msg['follow_up_questions']
                                              as List<dynamic>?)
                                          ?.map((e) => e.toString())
                                          .toList() ??
                                      [],
                                  token: msg['token'] ?? '',
                                  isMapView: false,
                                  expandChainOfThought: adjustedIndex ==
                                      viewModel.messages.length - 1,
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
                          valueListenable: viewModel.showLoader,
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
        );
      },
    );
  }

  Widget bottomBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chatInput(),
          _dropdownInsideField(),
        ],
      ),
    );
  }

  _chatInput() {
    return Column(
      children: [
        TextFormField(
          controller: viewModel.chatController,
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
      ],
    );
  }

  _speechButton() {
    return ValueListenableBuilder(
      valueListenable: listeningActive,
      builder: (context, value, _) {
        return IconButton(
          onPressed: !value
              ? (AppState.instance.language.toLowerCase() == 'telugu')
                  ? _startListeningTelugu
                  : _startListening
              : _stopListening,
          icon: Icon(
            !value ? Icons.mic_off : Icons.mic,
            color: Colors.grey,
          ),
          tooltip: 'Listen',
        );
      },
    );
  }

  _sendButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: viewModel.showLoader,
          builder: (context, value, _) {
            return IconButton(
                icon: Icon(Icons.send,
                    color: viewModel.showLoader.value ? Colors.grey : Colors.blue),
                     onPressed: viewModel.showLoader.value
                    ? null
                    : () async {
                        if (viewModel.chatController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Please enter your question.");
                        } else {
                          viewModel.sendMessage(context, viewModel.chatController.text);
                          // viewModel.sendMessageStream(viewModel.chatController.text,widget.sessionId);
                        }
                      });
          },
        ),
      ],
    );
  }

  /// Each time to start a speech recognition session
  _startListeningTelugu() async {
    print("_onSpeechResult_startListening BEFORE loop");
    var locales = await _speechToText.locales();
    for (int i = 0; i < locales.length; i++) {
      print("LOCALESDSD $i   ${locales[i].name}");
    }

    //for android tab english locale at 5
    print("_onSpeechResult_startListening langId $langId");
    SpeechRecognitionResult result;
    try {
      await _speechToText.listen(
          onSoundLevelChange: onSoundLevelChange,
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

  Future<void> _initRecorder() async {
    await tts.stop();
    await _audioRecorder.openRecorder();

    await Permission.microphone.request();

    _audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  Future<void> _startListening() async {
    await tts.stop();
    try {
      if (_audioRecorder.isRecording) {
        await _audioRecorder.stopRecorder();
      }

      channel = WebSocketChannel.connect(
        Uri.parse("ws://acerkrishidss.vassarlabs.com/chatbot_transcribe"),
      );
      channel!.sink.add(jsonEncode({"timestamps": true}));

      await _audioRecorder.openRecorder();
      ;

      bool isPcmSupported =
          await _audioRecorder.isEncoderSupported(fs.Codec.pcm16WAV);
      if (!isPcmSupported) throw Exception("pcm16 codec not supported.");

      _audioStreamController = StreamController<Uint8List>();
      List<int> audioBuffer = [];

      _audioStreamController.stream.listen((Uint8List data) async {
        audioBuffer.addAll(data);

        const bufferSize = 1024 * 16;
        if (audioBuffer.length >= bufferSize) {
          channel!.sink.add(Uint8List.fromList(audioBuffer));
          audioBuffer.clear();
        }
      });

      viewModel.chatController.text = '';

      await _audioRecorder.startRecorder(
        codec: fs.Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 16,
        toStream: _audioStreamController.sink,
      );

      _isRecording = true;
      listeningActive.value = true;

      // Start listening for WebSocket responses
      channel!.stream.listen((event) {
        final decoded = jsonDecode(event);
        final String? transcript = decoded['text']?.toString().trim();

        // Only if real user speech is detected (non-empty and new)
        if (transcript != null &&
            transcript.isNotEmpty &&
            transcript != _lastRecognizedText) {
          _lastRecognizedText = transcript;
          updateChatControllerForSpeech(transcript);

          // Reset inactivity timer
          _inactivityTimer?.cancel();
          _inactivityTimer = Timer(Duration(seconds: 2), () {
            _stopListening(); // Stop if no user voice for 2 seconds
          });
        }
      });

      // Start fallback inactivity timer
      _inactivityTimer = Timer(Duration(seconds: 2), () {
        _stopListening();
      });
    } catch (e) {
      print("WebSocket/audio error: $e");
      Fluttertoast.showToast(msg: "Error starting transcription.");
    }
  }

  Future<void> _stopListening() async {
    try {
      _inactivityTimer?.cancel();
      if (_audioRecorder.isRecording) {
        await _audioRecorder.stopRecorder();
      }
      await _audioStreamController.close();
      channel?.sink.close();
      _isRecording = false;
      listeningActive.value = false;
      setState(() {});
      print("Stopped listening due to inactivity.");
    } catch (e) {
      print("Error stopping listening: $e");
    }
  }

  dynamic Function(double)? onSoundLevelChange(double value) {
    print("onSoundLevelChange  $value");
    return null;
  }

/*  void _stopListening() async {
    bool active = _speechToText.isListening;
    listeningActive.value = active;
    _audioStreamController.close();
    _audioRecorder.closeRecorder();
    _isRecording = false;
    setState(() {});
  }*/

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    updateChatControllerForSpeech(result.recognizedWords);
    bool active = _speechToText.isListening;
    listeningActive.value = active;
  }

  void updateChatControllerForSpeech(String text) {
    viewModel.chatController.text = text;
    setState(() {});
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

  // Function to save audio data to a file
  Future<void> _saveAudioToFile(Uint8List data) async {
    try {
      Directory? dir;

      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download'); // Android Downloads
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      }

      String _filePath =
          '${dir!.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

      print("Audio saved to: $_filePath");
    } catch (e) {
      print("Error saving audio to file: $e");
    }
  }

  Widget _dropdownInsideField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      // Align with input field
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text('Select Language', style: constants.grey12W400),
          value: viewModel.langSelected,
          isExpanded: true,
          onChanged: (newValue) async {
            setState(() {
              viewModel.langSelected = newValue!;
              AppState.instance.language = viewModel.langSelected ?? '';
            });

            if (AppState.instance.language.toLowerCase() == 'telugu') {
              AppState.instance.language = 'Telugu';
              AppState.instance.isEnglish = false;
              langId = 'te-IN';
              language = 'telugu';
              currentVoice = {"name": "te-in-x-tef-local", "locale": "te-IN"};
            }
            if (AppState.instance.language.toLowerCase() == 'english') {
              AppState.instance.language = 'English';
              AppState.instance.isEnglish = true;
              langId = 'en-US';
              language = 'english';
              currentVoice = {"name": "en-us-x-iom-local", "locale": "en-US"};
            }
            await tts.setVoice(currentVoice);
            await tts.setLanguage(langId);
            await tts.setSpeechRate(0.5);
            print("12345 current voice :: $currentVoice langId - $langId");
            Fluttertoast.showToast(
                msg: "Switched to ${AppState.instance.language}");
          },
          items: viewModel.langList
              .map(
                  (model) => DropdownMenuItem(value: model, child: Text(model)))
              .toList(),
        ),
      ),
    );
  }
}
