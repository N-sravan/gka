import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/settings_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart' as record;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../chat_bubble.dart';
import 'package:http/http.dart' as http;
import '/utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import 'agent_step.dart';
import 'drawer_widget.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.isFromHistory,
    this.sessionId,
  });

  final bool? isFromHistory;
  final String? sessionId;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _recorder = record.AudioRecorder();
  final ValueNotifier<bool> listeningActive = ValueNotifier(false);
  late String recordedFilePath;
  var scrollControllerListView = ScrollController();
  StreamController<Uint8List> streamController = StreamController<Uint8List>();
  final SpeechToText _speechToText = SpeechToText();
  late ChatViewModel viewModel;
  bool _speechEnabled = false;
  FlutterTts tts = FlutterTts();

  IOWebSocketChannel? channel;

  // final _audioRecorder = fs.FlutterSoundRecorder();
  final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>();
  int prevChatLength = 0;

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
    _initAppStateValues();
    _initSpeech();
    _initRecorder();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isFromHistory != null && widget.isFromHistory == true) {
        await viewModel.getMessageHistoryForSession(widget.sessionId!, context);
      }
    });
  }

  _initAppStateValues() {
    AppState.instance.isEnglish = true;
    AppState.instance.language = 'English';
    AppState.instance.sttMode = 'Native';
    AppState.instance.ttsMode = 'Native';
    AppState.instance.transMode = 'Bhashini';
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
      debugLogging: true,
    );

    if (_speechEnabled) {
      var locales = await _speechToText.locales();
      await viewModel.setlangCodes();
      await tts.setLanguage(viewModel.langId);
      await tts.setSpeechRate(0.5);
      await tts.setVoice(currentVoice);
    } else {
      print("Speech recognition is not available on this device.");
    }
  }

  @override
  void dispose() {
    super.dispose();
    // _audioRecorder.closeRecorder();
    _audioStreamController.close();
    _isRecording = false;
    tts.stop();
    viewModel.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, viewModel, child) {
        return Scaffold(
          drawer: (widget.isFromHistory ?? false) ? null : const DrawerWidget(),
          appBar: AppBar(
            leading: (widget.isFromHistory ?? false)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            titleSpacing: 2,
            title: Row(
              children: [
                Image.asset('assets/images/apaims_logo.png', height: 32),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildChatList(),
              _buildLoaderWidget(),
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

  Widget _buildLoaderWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0),
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

  Widget _buildChatList() {
    return Expanded(
      child: ListView.builder(
        controller: scrollControllerListView,
        reverse: true,
        padding: const EdgeInsets.all(10),
        // itemCount: viewModel.messages.length + (viewModel.isStreaming.value ? 1 : 0),
        itemCount: viewModel.messages.length,
        itemBuilder: (_, index) {
          final adjustedIndex = viewModel.isStreaming.value
              ? viewModel.messages.length - index
              : viewModel.messages.length - 1 - index;

          if (adjustedIndex < 0 || adjustedIndex >= viewModel.messages.length) {
            return const SizedBox();
          }

          final msg = viewModel.messages[adjustedIndex];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ChatBubble(
              expandContentBlocks: false,
              contentBlocks: msg['content_blocks'],
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
              followUpQuestions: (msg['follow_up_questions'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
              token: msg['token'] ?? '',
              isMapView: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgentStepsOverlay(ChatViewModel viewModel) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewModel.isStreaming,
      builder: (context, isStreaming, _) {
        if (isStreaming && viewModel.currentSteps.isNotEmpty) {
          return ValueListenableBuilder<bool>(
            valueListenable: viewModel.showAgentSteps,
            builder: (context, showSteps, _) {
              if (!showSteps) return const SizedBox();

              return Positioned(
                bottom: 10,
                right: 10,
                width: 300,
                height: 400,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Agent Steps',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                ValueListenableBuilder<bool>(
                                  valueListenable: viewModel.expandAllSteps,
                                  builder: (_, expanded, __) => IconButton(
                                    icon: Icon(expanded
                                        ? Icons.unfold_less
                                        : Icons.unfold_more),
                                    tooltip: expanded
                                        ? 'Collapse All'
                                        : 'Expand All',
                                    onPressed: viewModel.toggleExpandAllSteps,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      viewModel.showAgentSteps.value = false,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: viewModel.expandAllSteps,
                          builder: (_, expandAll, __) => ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: viewModel.currentSteps.length,
                            itemBuilder: (context, index) {
                              return AgentStepWidget(
                                step: viewModel.currentSteps[index],
                                shouldExpand: expandAll,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildStreamingControls(ChatViewModel viewModel) {
    final hasContent =
        viewModel.messages.isNotEmpty || viewModel.currentSteps.isNotEmpty;

    if (!hasContent) {
      return SizedBox();
    }
    if (widget.isFromHistory != null && widget.isFromHistory == false) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: viewModel.showAgentSteps,
              builder: (context, showSteps, _) {
                return TextButton.icon(
                  icon:
                      Icon(showSteps ? Icons.visibility_off : Icons.visibility),
                  label: Text(showSteps ? 'Hide Steps' : 'Show Steps'),
                  onPressed: viewModel.toggleAgentSteps,
                );
              },
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextFormField(
        controller: viewModel.chatController,
        maxLines: null,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Ask AI anything...',
          hintStyle: constants.lightGrey2_14W400,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4BA164), width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          prefixIcon: _speechButton(),
          suffixIcon: _sendButton(),
        ),
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

  Widget _speechButton() {
    return ValueListenableBuilder(
      valueListenable: listeningActive,
      builder: (context, value, _) {
        return IconButton(
          // onPressed: !value ? _startListening : _stopListening,
          onPressed: () {
            print("listeningActive $value");
            if (!value) {
              if (AppState.instance.sttMode.toLowerCase() == 'native') {
                _startListeningNative();
              }
              if (AppState.instance.sttMode.toLowerCase() == 'parakeet') {
                _startListeningParakeet();
              }
              if (AppState.instance.sttMode.toLowerCase() == 'bhashini') {
                _startListeningBhashini();
              }
            } else {
              _stopListening();
            }
          },
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
                    color:
                        viewModel.showLoader.value ? Colors.grey : Colors.blue),
                onPressed: viewModel.showLoader.value
                    ? null
                    : () async {
                        if (viewModel.chatController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Please enter your question.");
                        } else {
                          // viewModel.sendMessage(context, viewModel.chatController.text);
                          print(
                              "userId : ${AppState.instance.userId}, sessionId :${AppState.instance.sessionId}");
                          if (viewModel.chatController.text.isNotEmpty &&
                              viewModel.chatController.text !=
                                  'Processing...') {
                            viewModel.sendMessageStream(
                                viewModel.chatController.text, context);
                          }
                        }
                      });
          },
        ),
      ],
    );
  }

  Future<void> _startListeningBhashini() async {
    viewModel.updateChatControllerForSpeech('');
    await _initRecorder();
    Directory tempDir = await getTemporaryDirectory();
    recordedFilePath =
        '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch.toString()}.flac';
    print("12345 file- $recordedFilePath");

    await _recorder.start(
      const record.RecordConfig(
        encoder: record.AudioEncoder.flac,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: recordedFilePath,
    );
    listeningActive.value = true;
  }

  Future<void> _stopListening() async {
    if (AppState.instance.sttMode.toLowerCase() == 'bhashini' &&
        recordedFilePath.isNotEmpty) {
      await _recorder.stop();
      await viewModel.sendAudioToAPI(recordedFilePath, context);
    }
    if (AppState.instance.sttMode.toLowerCase() == 'parakeet') {
      await _recorder.stop();
      await viewModel.sendAudioForTranscription(recordedFilePath, context);
    }

    listeningActive.value = false;
    setState(() {});
  }

  /// Each time to start a speech recognition session
  _startListeningNative() async {
    var locales = await _speechToText.locales();
    for (int i = 0; i < locales.length; i++) {
      print("LOCALESDSD $i   ${locales[i].name}");
    }

    try {
      await _speechToText.listen(
          onSoundLevelChange: onSoundLevelChange,
          localeId: AppState.instance.isEnglish ? 'en-IN' : 'te-IN',
          partialResults: true,
          onResult: _onSpeechResult,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 30),
          cancelOnError: true);
    } catch (e) {
      print('EXCEPTIONKJSKFJK An exception occurred: $e');
    }

    bool active = _speechToText.isListening;
    tts.stop();
    listeningActive.value = active;
  }

  Future<void> _initRecorder() async {
    await tts.stop();
    // await _audioRecorder.openRecorder();
    await Permission.microphone.request();
    // _audioRecorder.setSubscriptionDuration(const Duration(milliseconds: 100));
  }

  /*Future<void> _startListeningParakeet() async {
    await tts.stop();
    try {
      if (_audioRecorder.isRecording) {
        await _audioRecorder.stopRecorder();
      }

      channel = IOWebSocketChannel.connect(
        Uri.parse("ws://acerkrishidss.vassarlabs.com/chatbot_transcribe"),
      );
      channel!.sink.add(jsonEncode({"timestamps": true}));

      await _audioRecorder.openRecorder();

      bool isPcmSupported =
          await _audioRecorder.isEncoderSupported(fs.Codec.pcm16WAV);
      if (!isPcmSupported) throw Exception("pcm16 codec not supported.");

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
          viewModel.updateChatControllerForSpeech(transcript);

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
  }*/
  Future<void> _startListeningParakeet() async {
    await tts.stop();
    viewModel.updateChatControllerForSpeech('');
    Directory tempDir = await getTemporaryDirectory();
    recordedFilePath =
        '${tempDir.path}/audio_parakeet_${DateTime.now().millisecondsSinceEpoch.toString()}.wav';
    print("12345 file- $recordedFilePath");

    await _recorder.start(
      const record.RecordConfig(
        encoder: record.AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: recordedFilePath,
    );
    listeningActive.value = true;
  }

  dynamic Function(double)? onSoundLevelChange(double value) {
    print("onSoundLevelChange  $value");
    return null;
  }

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    viewModel.updateChatControllerForSpeech(result.recognizedWords);
    bool active = _speechToText.isListening;
    listeningActive.value = active;
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
        dir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      }

      String filePath =
          '${dir!.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

      print("Audio saved to: $filePath");
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
              AppState.instance.language = 'telugu';
              AppState.instance.isEnglish = false;
            }
            if (AppState.instance.language.toLowerCase() == 'english') {
              AppState.instance.language = 'english';
              AppState.instance.isEnglish = true;
            }
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
