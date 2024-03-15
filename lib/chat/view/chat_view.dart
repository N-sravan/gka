import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/login/model/department_user_permission_response.dart'
as response;
import 'package:provider/provider.dart';

import '../../chat_window.dart';

class ChatView extends StatelessWidget {
  final response.Meta userData;

  const ChatView(this.userData, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Session'),
      ),
      body: Consumer<ChatViewModel>(
        builder: (_, model, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SizedBox(
                  width: 104,
                  height: 104,
                  child: GestureDetector(
                    onTap: () async {
                      final viewModel = Provider.of<ChatViewModel>(
                          context,
                          listen: false);
                      await viewModel.createSession(userData);
                      if (viewModel.sessionId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatWindow(
                              isFirstTime: viewModel.isFirstTime,
                              finishSession: (bool finishSession) {
                                if (finishSession) {
                                  viewModel.updateFirstTimeValue();
                                }
                              },
                              sessionId: viewModel.sessionId!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Image.asset('assets/images/mic.png'),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
