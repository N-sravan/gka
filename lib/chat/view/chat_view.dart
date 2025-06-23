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
import '../../camera_screen.dart';
import '../../chat_bubble.dart';
import 'package:http/http.dart' as http;
import '../model/processing_step_model.dart';
import '/utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import 'agent_step.dart';
import 'drawer_widget.dart';
import 'thinking_container_widget.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.isFromHistory,
    required this.sessionId,
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
    viewModel.stopSpeaking();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          drawer: (widget.isFromHistory ?? false) ? null : const DrawerWidget(),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: (widget.isFromHistory ?? false)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
            titleSpacing: 2,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Image.asset('assets/images/apaims_logo.png', height: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'APAIMS Assistant',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'AI-Powered Chat',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(Icons.settings_outlined,
                      color: Colors.grey[700], size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Column(
              children: [
                _buildChatList(),
                _buildThinkingContainer(),
                _buildLoaderWidget(),
                SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: bottomBar(),
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

  Widget _buildThinkingContainer() {
    return ValueListenableBuilder<bool>(
      valueListenable: viewModel.isQueryProcessing,
      builder: (context, isProcessing, _) {
        // Check if chain of actions should be shown based on user settings
        if (!AppState.instance.showChainOfActions) {
          return const SizedBox();
        }

        // Only show for currently processing queries (not completed ones)
        if (!isProcessing) {
          return const SizedBox();
        }

        // Show the container for active processing
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ThinkingContainerWidget(
            steps: viewModel.processingSteps,
            isProcessing: isProcessing,
            totalDuration: viewModel.totalProcessingDuration,
            includeDetails: AppState.instance.showDetailedMode,
            onToggle: viewModel.toggleThinkingContainer,
          ),
        );
      },
    );
  }

  // Helper methods for message-specific thinking containers
  bool _shouldShowThinkingContainerForMessage(Map<String, dynamic> message) {
    // Only show for non-user messages that have processing steps and if settings allow
    return AppState.instance.showChainOfActions &&
        !message['is_user'] &&
        message['processing_steps'] != null &&
        (message['processing_steps'] as List).isNotEmpty;
  }

  List<ProcessingStepModel> _getProcessingStepsFromMessage(
      Map<String, dynamic> message) {
    final stepsData = message['processing_steps'] as List?;
    if (stepsData == null) return [];

    return stepsData.map((stepData) {
      if (stepData is ProcessingStepModel) {
        return stepData;
      }
      // If the data is stored as Map (serialized), reconstruct ProcessingStepModel
      return ProcessingStepModel.fromJson(stepData as Map<String, dynamic>);
    }).toList();
  }

  int _getTotalDurationFromMessage(Map<String, dynamic> message) {
    final steps = _getProcessingStepsFromMessage(message);
    return steps
        .where((step) => step.duration != null)
        .fold(0, (sum, step) => sum + step.duration!);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ChatBubble(
                  expandContentBlocks: false,
                  contentBlocks: msg['content_blocks'],
                  timestamp: '${DateTime.now().millisecondsSinceEpoch}',
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
                  followUpQuestions:
                      (msg['follow_up_questions'] as List<dynamic>?)
                              ?.map((e) => e.toString())
                              .toList() ??
                          [],
                  token: msg['token'] ?? '',
                  isMapView: false,
                ),
                if (_shouldShowThinkingContainerForMessage(msg))
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: ThinkingContainerWidget(
                      steps: _getProcessingStepsFromMessage(msg),
                      isProcessing: false,
                      totalDuration: _getTotalDurationFromMessage(msg),
                      includeDetails: AppState.instance.showDetailedMode,
                      onToggle: null,
                    ),
                  ),
              ],
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
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: viewModel.chatController,
            maxLines: null,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Ask anything..',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              prefixIcon: _speechButton(),
              suffixIcon: _sendButton(),
            ),
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
        viewModel.capturedPhoto == null
            ? CameraWidget(saveCapturedPhoto: viewModel.saveCapturedPhoto)
            : Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      viewModel.capturedPhoto = null;
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
                          image: FileImage(File(viewModel.capturedPhoto!.path)),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
                        // Hide keyboard immediately when send button is pressed
                        FocusScope.of(context).unfocus();

                        if (viewModel.chatController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Please enter your question.");
                        } else {
                          debugPrint(
                              "userId : ${AppState.instance.userId}, sessionId :${widget.sessionId}");
                          if (viewModel.chatController.text.isNotEmpty &&
                              widget.sessionId != null &&
                              widget.sessionId!.isNotEmpty &&
                              viewModel.chatController.text !=
                                  'Processing...') {
                            if (viewModel.capturedPhoto != null) {
                              await viewModel.uploadMediaToS3();
                            } else {
                              viewModel.imageUrl = '';
                            }
                            viewModel.sendMessageWithQueryStream(
                                widget.sessionId, context);
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
          onChanged: (newValue) {
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
            Fluttertoast.showToast(msg: "Switched to ${AppState.instance.language}");
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
