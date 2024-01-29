import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gka/cart_item.dart';
import 'package:gka/chat_bubble.dart';
import 'package:gka/shoppingCartOverlay.dart';
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
  int prevChatLength = 0;
  TextToSpeech tts = TextToSpeech();
  // Create a transparent overlay to cover the whole screen
  OverlayEntry? overlayEntry;

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


    // Some UI or other code to select a locale from the list
    // resulting in an index, selectedLocale

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
    var selectedLocale = locales[5];

    //for android tab english locale at 5
    print("_onSpeechResult_startListening");
    try {
      await _speechToText.listen(onSoundLevelChange: onSoundLevelChange, localeId: selectedLocale.localeId, partialResults: false, onResult: _onSpeechResult, pauseFor: Duration(seconds: 3), listenFor : Duration(seconds: 15), cancelOnError: true);
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
    DatabaseReference ref = FirebaseDatabase.instance.ref("ND_ASSISTANT/${widget.sessionId}");

    await ref.push().set({
        "isUser": true,
        "message": result.recognizedWords
    });
    bool active = _speechToText.isListening;
    listeningActive.value = active;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        *//*actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
                onTap: () async {
                  DatabaseReference ref = FirebaseDatabase.instance.ref("KFC/${widget.sessionId}");

                  await ref.set(null);`
                  if (overlayEntry != null) {
                    overlayEntry!.remove();
                  }
                  tts.stop();
                  widget.finishSession(true);
                },
                child: const Icon(Icons.cancel)),
          )
        ],*//*
      ),*/
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseDatabase.instance.ref("ND_ASSISTANT/${widget.sessionId}").onValue,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null) {
                    List<ChatBubble> messageList = [];
                      var data = (snapshot.data! as DatabaseEvent)
                          .snapshot
                          .value ?? {};
                      print("DATAFJLDLFHGLD $data");
                      data = data as Map<dynamic, dynamic>;
                    var sortedByKeyMap = Map.fromEntries(
                        data.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
                      sortedByKeyMap.forEach((key, value) {
                        if (key != "cart" ) {
                          final datalast = Map<String, dynamic>.from(value);
                          print("SORTED MESSAGES ${datalast['message']}");
                          messageList.add(ChatBubble(
                              text: datalast['message'],
                              isUser: datalast['isUser']));
                        } else {
                          if (overlayEntry != null) {
                            overlayEntry!.remove();
                          }
                          Cart cart = Cart.fromJson(jsonDecode(jsonEncode(value)));
                          print("CARTITEMS  ${cart.items}");
                          showShoppingCartOverlay(context, cart);
                        }
                      });
                      //messageList.reversed;
                      if (messageList.isNotEmpty && !messageList[messageList.length - 1].isUser && messageList.length > prevChatLength) {
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) {
                          showLoader.value = false;
                            });
                        tts.speak(messageList[messageList.length - 1].text);
                      }
                    prevChatLength = messageList.length;

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
                          child: Image.asset('assets/images/chat_loading_medico.gif'));
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
                      glowColor: Colors.purple,
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

  void showShoppingCartOverlay(BuildContext context, Cart cart) {

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 20,
        left: 520,
        width: 600,
        child: ShoppingCartOverlay(
          cart: cart,
          onClose: () {
            // Remove the overlay when the user closes the shopping cart
            overlayEntry!.remove();
          },
        ),
      ),
    );

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      Overlay.of(context).insert(overlayEntry!);
    });
  }
}
