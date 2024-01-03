import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat_bubble.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';

class ChatWindow extends StatefulWidget {
  ChatWindow({
    Key? key,required this.isFirstTime, required this.finishSession, required this.sessionId
  }) : super(key: key);

  bool isFirstTime;
  final Function(bool finishSession) finishSession;
  final String sessionId;

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  var scrollControllerListView = ScrollController();
  int counter = 1;
  TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    tts.setRate(1);
  }

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    print("Available voices ${await tts.getVoice()}");
    print("Available languages ${await tts.getLanguages()}");
    await tts.setLanguage("en-US");
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    print("_onSpeechResult_startListening");
    await _speechToText.listen(partialResults: false, onResult: _onSpeechResult, pauseFor: Duration(seconds: 2));
    bool active = _speechToText.isListening;
    tts.stop();
    listeningActive.value = active;
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
    DatabaseReference ref = FirebaseDatabase.instance.ref("KFC/${widget.sessionId}");

    await ref.child(DateTime.now().millisecondsSinceEpoch.toString()).set({
        "isUser": true,
        "message": result.recognizedWords
    });
    bool active = _speechToText.isListening;
    listeningActive.value = active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            widget.finishSession(true);
          },
            child: const Icon(Icons.cancel)),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseDatabase.instance.ref("KFC/${widget.sessionId}").onValue,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null) {
                    List<ChatBubble> messageList = [];
                      var data = (snapshot.data! as DatabaseEvent)
                          .snapshot
                          .value ?? {};
                      data = data as Map<dynamic, dynamic>;
                    var sortedByKeyMap = Map.fromEntries(
                        data.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
                      sortedByKeyMap.forEach((key, value) {
                      final datalast = Map<String, dynamic>.from(value);
                      print("SORTED MESSAGES ${datalast['message']}");
                      messageList.add(ChatBubble(
                          text: datalast['message'],
                          isUser: datalast['isUser']));
                      });
                      //messageList.reversed;
                      if (messageList.isNotEmpty && !messageList[messageList.length - 1].isUser) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) {
                          showLoader.value = false;
                            });

                        tts.speak(messageList[messageList.length - 1].text);
                      }

                      if (messageList.isNotEmpty && messageList[messageList.length - 1].isUser) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) {
                          showLoader.value = true;
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
                            child: messageList[messageList.length -1-index],
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
                child : ValueListenableBuilder(
                  valueListenable: showLoader,
                  builder: (context, value, _) {
                    if (value) {
                      return SizedBox(
                        height: 100,
                          width: 100,
                          child: Image.asset('assets/images/chat_loading.gif'));
                    }
                    return SizedBox() ;
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child : ValueListenableBuilder(
                  valueListenable: listeningActive,
                  builder: (context, value, _) {
                    return AvatarGlow(
                      animate: value,
                      glowColor: Colors.green,
                      child: FloatingActionButton(
                        onPressed:
                        // If not yet listening for speech start, otherwise stop
                        !value
                            ? _startListening
                            : _stopListening,
                        tooltip: 'Listen',
                        child: Icon(
                            !value ? Icons.mic_off : Icons.mic),
                      ),
                    );
                  },
                ),// your widget would go here
              ),
            )
          ],
        ),
      ),
    );
  }
}
