import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/utils/app_state.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../../chat_bubble.dart';
import '../../chat_window.dart';

class ChatHistoryView extends StatefulWidget {
  final String? sessionId;

  const ChatHistoryView({Key? key, this.sessionId}) : super(key: key);

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  late ChatViewModel viewModel;
  var scrollControllerListView = ScrollController();

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
            body: viewModel.chatDataList.isNotEmpty
                ? ListView.builder(
                  itemCount: viewModel.chatDataList.length,
                  itemBuilder: (context, index) {
                    final chat = viewModel.chatDataList[index];
                    return ChatBubble(
                      text: chat.message ?? '',
                      isUser: chat.isUser,
                      isMapView: false,
                      imageUrl: null,
                      tableColumnData: null,
                      tableRowData: null,
                      logMessage: null,
                      errorLog: null,
                      hasErrorLog: false,
                      timestampMapping: null,
                      sessionId: null,
                      chainOfThoughts: null,
                      followUpQuestions: [],
                      token: null,
                      expandChainOfThought: false,
                      sessionExpired: false,
                    );
                  },
                )
                : const Center(
                  child: Text('No Chat history!'),
                ),
          ),
        );
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
}
