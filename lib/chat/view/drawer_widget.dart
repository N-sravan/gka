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

  // bool AppState.instance.isListeningMode = false;
  Timer? periodicTimer;

  // late ChatViewModel viewModel;

  @override
  void initState() {
    AppState.instance.mode = 'dashboard';
    mode = AppState.instance.mode;
/*    if (mode.isNotEmpty) {
      if (mode == 'data_interaction_chat') {
        isDisplay = true;
      } else {
        isDisplay = false;
      }
    }*/
    // viewModel = Provider.of<ChatViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                      color: Colors.green,
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
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Notifications",
                        style: constants.appBarListTileTextStyle,
                      ),
                      const Icon(Icons.notifications),
                    ],
                  ),
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsView(),
                      ),
                    );
                  },
                ),
                AppState.instance.role == 'fieldwise super admin'
                    ? ListTile(
                        trailing: const Icon(Icons.upload_file),
                        title: Row(
                          children: [
                            Text(
                              "User Management",
                              style: constants.appBarListTileTextStyle,
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserManagementView(),
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
                AppState.instance.role == 'fieldwise super admin'
                    ? ListTile(
                        trailing: const Icon(Icons.upload_file),
                        title: Row(
                          children: [
                            Text(
                              "Knowledge Bank Management",
                              style: constants.appBarListTileTextStyle,
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DocumentsView(),
                            ),
                          );
                        },
                      )
                    : const SizedBox(),
                ListTile(
                  trailing: const Icon(Icons.manage_accounts),
                  title: Row(
                    children: [
                      Text(
                        "Prompt Management",
                        style: constants.appBarListTileTextStyle,
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PromptManagementView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  trailing: Transform.scale(
                      scale: 0.60,
                      child: Switch(
                        inactiveThumbColor: Colors.black,
                        activeColor: Colors.green,
                        value: isListeningMode,
                        onChanged: (bool value) {
                          setState(() {
                            isListeningMode = !isListeningMode;
                          });
                        },
                      )),
                  onTap: () async {
                    AppState.instance.isListeningMode = isListeningMode;
                    print(
                        "AppState.instance.isListeningMode::${AppState.instance.isListeningMode}");
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatWindow(
                          isFromHistory: false,
                          // isFirstTime: widget.isFirstTime!,
                          sessionId: widget.sessionId!,
                        ),
                      ),
                    );
                    if (AppState.instance.isListeningMode) {
                      // If switching to Always listening mode
                      // autoSessionId = const Uuid().v4();
                      await tts.stop();
                      await initializeService();
                    } else {
                      listeningActive.value = false;
                      await tts.stop();
                      final service = FlutterBackgroundService();
                      var isRunning = await service.isRunning();
                      if (isRunning) {
                        service.invoke("stopService");
                      }
                      // await _speechToText.stop(); // Stop speech recognition
                      if (periodicTimer != null && periodicTimer!.isActive) {
                        periodicTimer?.cancel();
                      }
                    }
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Conversational Mode",
                        style: constants.appBarListTileTextStyle,
                      ),
                    ],
                  ),
                ),
/*
                ListTile(
                  trailing: Transform.scale(
                    scale: 0.60, // Reduce the size of the switch
                    child: Switch(
                      inactiveThumbColor: Colors.black,
                      activeColor: Colors.green,
                      value: !AppState.instance.isEnglish,
                      onChanged: (bool value) {
                        setState(() {
                          AppState.instance.isEnglish =
                              !AppState.instance.isEnglish;
                          AppState.instance.language = 'hindi';
                          print("lang::${AppState.instance.language}");
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatWindow(
                                isFromHistory: false,
                                sessionId: widget.sessionId,
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                  title: Text(
                    "Hindi Language",
                    style: constants.appBarListTileTextStyle,
                  ),
                ),
*/
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
