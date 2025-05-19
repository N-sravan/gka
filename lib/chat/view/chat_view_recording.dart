import 'dart:async';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../chat_bubble.dart';
import '/utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import 'drawer_widget.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
    this.isFromHistory,
    this.sessionId,
  }) : super(key: key);

  final bool? isFromHistory;
  final String? sessionId;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ValueNotifier<bool> listeningActive = ValueNotifier(false);
  var scrollControllerListView = ScrollController();
  late ChatViewModel viewModel;
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String langId = 'en-IN';
  String language = '';
  FlutterTts tts = FlutterTts();
  final Map<String, String> questionsMap = {
    'hello' : 'Hello, how can I assist you today?',
    'Is there any risk of pests or disease in my paddy field this week':'Your paddy crop is 43 days old. Based on current weather patterns—high humidity and moderate temperature—there is a medium risk of pest infestation from Brown Planthopper (BPH) and Sheath Blight this week in your area.',
    'What are the Symptoms of the brown plant Hopper':
    'Symptoms of BPH include:\n. Hopper burn patches starting from the leaf tips\n. Presence of tiny brown insects on the lower parts of plants\n. Sudden yellowing and wilting of tillers',
    'How Should I control it':
    'For 0.75 acres, use 60 ml of Imidacloprid 17.8% SL mixed in 30 liters of water. Spray uniformly during early morning or evening. Avoid spraying during mid-day heat.',
    'Should I irrigate my field this week':
    'According to the forecast, your area (Alathur) is expected to remain dry over the next 5 days with temperatures around 34°C. Soil moisture is likely to be low. I recommend irrigating your field within the next 2 days, especially if no irrigation was done in the past week.',
  };

  void initState() {
    super.initState();
    AppState.instance.isEnglish = true;
    AppState.instance.language = 'english';
    langId = 'en-IN';
    // _initRecorder();
    _initSpeech();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await viewModel.initWebsocketConnection(context);
      if (widget.isFromHistory != null && widget.isFromHistory == true) {
        await viewModel.getMessageHistoryForSession(widget.sessionId!, context);
      }
    });
  }

  Future<void> _initSpeech() async {
    Map<String, String> currentVoice = {
      "name": "en-us-x-iom-local",
      "locale": "en-US"
    };
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
    tts.stop();
    showLoader.value = false;
    viewModel.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        return Scaffold(
          drawer: (widget.isFromHistory != null && widget.isFromHistory == true) ? null : const DrawerWidget(),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.green.withOpacity(0.7),
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
                  // 'assets/images/fieldrishi_appbar.png',
                  'assets/images/kathir_logo.png',
                  height: 40,
                ),
                /* const SizedBox(width: 8),
                const Text(
                  'APAIMS Chatbot',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),*/
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
                        valueListenable: showLoader,
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
                                  showLoader.value = true;
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

                              // STOP if user message came in
                              if (viewModel.messages.isNotEmpty &&
                                  viewModel.messages.last['is_user']) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  showLoader.value = true;
                                  // tts.stop();
                                });
                              }

                              viewModel.prevChatLength =
                                  viewModel.messages.length;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
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
                          valueListenable: showLoader,
                          builder: (context, value, _) {
                            if (value) {
                              return LoadingAnimationWidget.waveDots(
                                  color: Colors.green, size: 40);
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
          // _dropdownInsideField(),
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

  _sendButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: showLoader,
          builder: (context, value, _) {
            return IconButton(
              icon: Icon(Icons.send,
                  color: showLoader.value ? Colors.grey : Colors.green),
              onPressed: showLoader.value
                  ? null
                  : () async {
                      String userInput = viewModel.chatController.text.trim();
                      if (userInput.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Please enter your question.");
                        return;
                      }
                      showLoader.value = true;
                      viewModel.updateChatControllerForSpeech('');

                      String questionKey = userInput;
                      print("userIput::$userInput");
                      String? localAnswer = questionsMap[questionKey];
                      print("localAnswer::$localAnswer");

                      // Add user message
                      viewModel.messages.add({
                        'text': userInput,
                        'is_user': true,
                      });

                      if (localAnswer != null) {
                        await Future.delayed(const Duration(seconds: 3));
                        // Answer from local map
                        viewModel.messages.add({
                          'text': localAnswer,
                          'is_user': false,
                        });

                        showLoader.value = false;
                        tts.speak(localAnswer);
                        setState(() {});
                      }
                    },
            );
          },
        ),
      ],
    );
  }

  Widget _speechButton() {
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
          localeId: 'en-IN',
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

  Future<void> _onSpeechResult(SpeechRecognitionResult result) async {
    viewModel.updateChatControllerForSpeech(result.recognizedWords);
    bool active = _speechToText.isListening;
    listeningActive.value = active;
  }
}
