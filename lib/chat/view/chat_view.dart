import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/login/model/department_user_permission_response.dart' as response;
import 'package:provider/provider.dart';


import '../../chat_window.dart';

class ChatView extends StatefulWidget {
  final response.Meta userData;

  const ChatView(this.userData, {super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late ChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(builder: (_, model, child) {
      return Expanded(
          child: viewModel.isFirstTime
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 104,
                        height: 104,
                        child: GestureDetector(
                          onTap: () async {
                                await viewModel.createSession(widget.userData);
                      /*      if (newSessionId != null) {
                              setState(() {
                                viewModel.isFirstTime = false;
                                viewModel.sessionId = newSessionId;
                              });
                            }*/
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Image.asset('assets/images/mic.png')),
                        ),
                      ),
                    )
                  ],
                )
              : ChatWindow(
                  isFirstTime: viewModel.isFirstTime,
                  finishSession: (bool finishSession) {
                    if (finishSession) {
                      viewModel.updateFirstTimeValue();
                      /*setState(() {
                        viewModel.isFirstTime = true;
                      });*/
                    }
                  },
                  sessionId: viewModel.sessionId!,
                ));
    });
  }
}
