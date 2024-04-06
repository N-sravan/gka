// import 'dart:async';
// import 'dart:math';
//
// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import '../../chat_bubble.dart';
// import '../../login/model/login_api_response_model.dart' as response;
// import 'package:gka/chat/view_model/chat_view_model.dart';
// import 'package:provider/provider.dart';
// import '../../chat_window.dart';
// import 'drawer_widget.dart';
//
// class ChatWindow extends StatefulWidget {
//   final bool isFirstTime;
//   final Function(bool finishSession) finishSession;
//   final String sessionId;
//   final response.Content? data;
//
//   const ChatWindow(
//       {Key? key,
//       required this.isFirstTime,
//       required this.finishSession,
//       required this.sessionId,
//       this.data})
//       : super(key: key);
//
//   @override
//   State<ChatWindow> createState() => _ChatWindowState();
// }
//
// class _ChatWindowState extends State<ChatWindow> {
//   late ChatViewModel viewModel;
//   var scrollControllerListView = ScrollController();
//   FlutterTts tts = FlutterTts();
//   ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);
//   ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
//   late Timer periodicTimer;
//   Timer? dataTimer;
//   Timer? loadingTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     viewModel = Provider.of<ChatViewModel>(context, listen: false);
//     viewModel.initSpeech();
//     WidgetsBinding.instance.addPostFrameCallback((_) {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ChatViewModel>(
//       builder: (_, model, child) {
//         return WillPopScope(
//           onWillPop: () async {
//             /*bool? result = await showSessionDialog();
//             if (result) {
//               tts.stop();
//               _speechToText.stop();
//               // periodicTimer.cancel();
//               Navigator.pop(context);
//             }
//             return false;*/
//             return false;
//           },
//           child: Scaffold(
//             drawer: const DrawerWidget(),
//             appBar: AppBar(
//               centerTitle: true,
//               backgroundColor: Colors.white,
//               elevation: 0,
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'APWRIMS Bot',
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const Spacer(), // Add spacing between title and toggle
//                   Text(
//                     viewModel.toggleValue ? 'External LLM' : 'Internal LLM',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color:
//                           viewModel.toggleValue ? Colors.black : Colors.green,
//                     ),
//                   ),
//
//                   IconButton(
//                     onPressed: () async {
//                       setState(() {
//                         viewModel.toggleValue =
//                             !viewModel.toggleValue; // Toggle the value
//                       });
//                       print("wewewewewew _toggleValue::$viewModel.toggleValue");
//                       /* if (!_toggleValue) {
//                     autoSessionId= Uuid().v4();
//                     periodicTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//                       await initializeSpeechToText(autoSessionId);
//                     });
//                   } else {
//                     await _speechToText.stop();
//                     await tts.stop();
//                     periodicTimer.cancel();
//                   }*/
//                     },
//                     icon: Icon(
//                       !viewModel.toggleValue
//                           ? Icons.toggle_on
//                           : Icons.toggle_off,
//                       color:
//                           !viewModel.toggleValue ? Colors.green : Colors.black,
//                       size: 30,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             body: Container(
//               color: Colors.grey[100],
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: StreamBuilder(
//                       stream: FirebaseDatabase.instance
//                           .ref("CHAT_BOT_ONDEMAND_QUERY_DATA/${viewModel.sessionId}")
//                           .onValue,
//                       builder: (context, AsyncSnapshot snapshot) {
//                         if (snapshot.hasData && snapshot.data != null) {
//                           List<ChatBubble> messageList = [];
//                           var data = (snapshot.data! as DatabaseEvent)
//                                   .snapshot
//                                   .value ??
//                               {};
//                           print("DATAFJLDLFHGLD $data");
//                           data = data as Map<dynamic, dynamic>;
//                           dataTimer?.cancel();
//                           loadingTimer?.cancel();
//                           var sortedByKeyMap = Map.fromEntries(
//                               data.entries.toList()
//                                 ..sort((e1, e2) => e1.key.compareTo(e2.key)));
//                           sortedByKeyMap.forEach((key, value) {
//                             if (key != "cart") {
//                               final datalast = Map<String, dynamic>.from(value);
//                               print("SORTED MESSAGES ${datalast['message']}");
//                               print("Session Id ${viewModel.sessionId}");
//                               messageList.add(ChatBubble(
//                                 text: datalast['message'],
//                                 isUser: datalast['isUser'],
//                                 imageUrl: datalast['mediaUrl'],
//                                 logMessage: datalast['log'] ?? '',
//                               ));
//                             }
//                           });
//                           //messageList.reversed;
//                           if (messageList.isNotEmpty &&
//                               !messageList[messageList.length - 1].isUser &&
//                               messageList.length > viewModel.prevChatLength) {
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               showLoader.value = false;
//                             });
//                             tts.speak(messageList[messageList.length - 1].text);
//                           }
//                           viewModel.prevChatLength = messageList.length;
//                           if (messageList.isNotEmpty &&
//                               messageList[messageList.length - 1].isUser) {
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               showLoader.value = true;
//                             });
//
//                             loadingTimer =
//                                 Timer(const Duration(seconds: 4), () {
//                               int randomIndex = Random()
//                                   .nextInt(viewModel.loaderMsgList.length);
//                               if (showLoader.value) {
//                                 tts.speak(viewModel.loaderMsgList[randomIndex]);
//                               }
//                             });
//
//                             dataTimer =
//                                 Timer(const Duration(seconds: 15), () {
//                               print("timerCounter::${viewModel.timerCounter}");
//                               if (showLoader.value) {
//                                 /* messageList.add(ChatBubble(
//                               text: "Data Not Found",
//                               isUser: false,
//                               imageUrl: "",
//                               logMessage: '',
//                             ));*/
//                                 WidgetsBinding.instance
//                                     .addPostFrameCallback((_) {
//                                   showLoader.value = false;
//                                 });
//                                 tts.speak("Data Not found");
//                               }
//                             });
//                           }
//
//                           return ListView.builder(
//                             reverse: true,
//                             physics: const AlwaysScrollableScrollPhysics(),
//                             controller: scrollControllerListView,
//                             addAutomaticKeepAlives: true,
//                             itemBuilder: (context, index) {
//                               if (index < messageList.length) {
//                                 return Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: messageList[
//                                       messageList.length - 1 - index],
//                                 );
//                               }
//                               return null;
//                             },
//                             itemCount: messageList.length,
//                           );
//                         }
//                         return const SizedBox();
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 80.0),
//                     child: Align(
//                       alignment: AlignmentDirectional.centerStart,
//                       child: ValueListenableBuilder(
//                         valueListenable:showLoader,
//                         builder: (context, value, _) {
//                           if (value) {
//                             return SizedBox(
//                                 height: 100,
//                                 width: 100,
//                                 child: Image.asset(
//                                     'assets/images/response_bubble.gif'));
//                           }
//                           return const SizedBox();
//                         },
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 30.0),
//                     child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: ValueListenableBuilder(
//                         valueListenable: listeningActive,
//                         builder: (context, value, _) {
//                           return AvatarGlow(
//                             animate: value,
//                             glowColor: Colors.purple,
//                             child: FloatingActionButton(
//                               onPressed:
//                                   // If not yet listening for speech start, otherwise stop
//                                   !value
//                                       ? viewModel.startListening
//                                       : viewModel.stopListening,
//                               tooltip: 'Listen',
//                               child: Icon(!value ? Icons.mic_off : Icons.mic),
//                             ),
//                           );
//                         },
//                       ), // your widget would go here
//                     ),
//                   ),
//                   /*Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: bottomBar(),
//               ),*/
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
