import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:gka/chat/view/prompt_management_view.dart';
import 'package:gka/chat/view/tool_inventory_view.dart';
import 'package:gka/chat/view/user_management_view.dart';
import 'package:gka/utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../chat_window.dart';
import '../../main.dart';
import 'chat_history_view.dart';
import 'documents_view.dart';
import 'notifications_view.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
    // required this.isFirstTime,
    required this.sessionId,
  }) : super(key: key);

  // final bool isFirstTime;
  final String sessionId;

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late String mode;
  bool isDisplay = true;
  bool isHindi = false;
  bool isListeningMode = false;

  Timer? periodicTimer;

  // late ChatViewModel viewModel;

  @override
  void initState() {
    // viewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: constants.appDrawerHeaderHeight,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0.0,
                            0.0,
                            constants.mediumPadding,
                            constants.largePadding * 0.25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: constants.mediumPadding,
                            ),
                            Expanded(
                              child: Text(
                                'Hello ${AppState.instance.userName}',
                                style: constants.appBarHeaderTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  trailing: const Icon(Icons.history),
                  title: Row(
                    children: [
                      Text(
                        "Chat History",
                        style: constants.appBarListTileTextStyle,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatHistoryView(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 40.0),
            child: ListTile(
              title: Row(
                children: [
                  Text(
                    "End Session",
                    style: constants.appBarListTileTextStyle,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      bool? result = await showSessionDialog();
                      if (result != null && result) {
                        // tts.stop();
                        // _speechToText.stop();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showSessionDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Do you want to end the session?',
            style: constants.black16W500,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                // bool? result = await viewModel.endSession();
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
