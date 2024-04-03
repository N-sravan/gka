import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';

import '../../chat_bubble.dart';

class HistoryChatView extends StatefulWidget {
  String? sessionId;

  HistoryChatView({Key? key, this.sessionId}) : super(key: key);

  @override
  State<HistoryChatView> createState() => _HistoryChatViewState();
}

class _HistoryChatViewState extends State<HistoryChatView> {
  late ChatViewModel viewModel;
  var scrollControllerListView = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'APWRIMS Bot',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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
                          .ref("CHAT_BOT_APWRIMS/${widget.sessionId}")
                          .onValue,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          List<ChatBubble> messageList = [];
                          var data = (snapshot.data! as DatabaseEvent)
                                  .snapshot
                                  .value ??
                              {};
                          print("DATAFJLDLFHGLD $data");
                          data = data as Map<dynamic, dynamic>;
                          var sortedByKeyMap = Map.fromEntries(
                              data.entries.toList()
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
                          //messageList.reversed;
                       /*   if (messageList.isNotEmpty &&
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
                          }*/

                          return ListView.builder(
                            reverse: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            controller: scrollControllerListView,
                            addAutomaticKeepAlives: true,
                            itemBuilder: (context, index) {
                              if (index < messageList.length) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: messageList[
                                      messageList.length - 1 - index],
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
