import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/utils/app_state.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../../chat_bubble.dart';
import '../../chat_window.dart';
import '../../main.dart';

class ChatHistoryView extends StatefulWidget {
  final String? sessionId;

  const ChatHistoryView({Key? key, this.sessionId}) : super(key: key);

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  late ChatViewModel viewModel;
  var scrollControllerListView = ScrollController();
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  TextEditingController chatController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String url = '';
  late final channel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.sessionId != null && widget.sessionId!.isNotEmpty) {
        await viewModel.getMessageHistoryForSession(widget.sessionId!, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        if (model.isLoading) {
          return child ?? const SizedBox();
        }
        return WillPopScope(
            onWillPop: () async {
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                title: Text('Chat History', style: constants.black16W500),
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

                            /*    // SPEAK LOGIC (for each new bot message)
                      if (_messages.isNotEmpty &&
                          !_messages.last['is_user'] &&
                          _messages.last['text'].toString().isNotEmpty &&
                          _messages.length > prevChatLength) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          showLoader.value = false;
                          _speakMessage(_messages.last['text']);
                        });
                      }*/

                            // STOP if user message came in
                            if (_messages.isNotEmpty &&
                                _messages.last['is_user']) {
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
                                followUpQuestions: (msg['follow_up_questions']
                                            as List<dynamic>?)
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
            ));
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: constants.appBarElevation,
          backgroundColor: Colors.black,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: constants.indicator,
        ),
      ),
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

  _sendButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: showLoader,
          builder: (context, value, _) {
            return IconButton(
                icon: Icon(Icons.send,
                    color: showLoader.value ? Colors.grey : Colors.blue),
                onPressed: showLoader.value
                    ? null
                    : () async {
                        if (chatController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Please enter your question.");
                        } else {
                          _sendMessage(chatController.text);
                        }
                      });
          },
        ),
      ],
    );
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

  String formatSession() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(AppState.instance.sessionId));
    // final formatted = DateFormat('MMM dd,HH:mm:ss').format(dateTime);
    final formatted = DateFormat('MMM dd-HH_mm_ss').format(dateTime);
    return 'Session $formatted';
  }
}
