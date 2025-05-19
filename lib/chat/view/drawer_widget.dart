import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/app_state.dart';
import 'package:provider/provider.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../chat_window.dart';
import '../../main.dart';
import '../view_model/chat_view_model.dart';
import 'chat_history_view.dart';
import 'chat_view.dart';
import 'chat_view_recording.dart';
import 'documents_view.dart';
import 'notifications_view.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    Key? key,
    // required this.isFirstTime,
  }) : super(key: key);

  // final bool isFirstTime;

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late String mode;
  bool isDisplay = true;
  bool isHindi = false;
  bool isListeningMode = false;

  Timer? periodicTimer;

  late ChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.getSessionsForUser(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Drawer(
            backgroundColor: Colors.white,
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    height: constants.appDrawerHeaderHeight,
                    width: double.infinity,
                    color: Colors.blue,
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Chat History',
                      style: constants.appBarHeaderTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: model.isLoading
                        ? Center(child: constants.indicator)
                        : ListView(
                            children: [
                              viewModel.sessionIdDataMapping.isNotEmpty
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: viewModel.sessionIdDataMapping.length,
                                        itemBuilder: (context, index) {
                                          final key = viewModel.sessionIdDataMapping.keys.elementAt(index);
                                          final value = viewModel.sessionIdDataMapping[key] ?? '';

                                          return Card(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 16.0),
                                            child: ListTile(
                                              trailing: PopupMenuButton<String>(
                                                icon:
                                                    const Icon(Icons.more_vert),
                                                onSelected:
                                                    (String valueSelected) {
                                                  if (valueSelected == 'edit') {
                                                    TextEditingController
                                                        controller =
                                                        TextEditingController(
                                                            text: key);
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Edit Session ID'),
                                                          content: TextField(
                                                            controller:
                                                                controller,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  "Enter new session ID",
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  'Cancel'),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Save'),
                                                              onPressed:
                                                                  () async {
                                                                String
                                                                    newSessionId =
                                                                    controller
                                                                        .text
                                                                        .trim();
                                                                bool updated = await viewModel
                                                                    .updateSessionId(
                                                                        context,
                                                                        key,
                                                                        newSessionId);

                                                                if (updated) {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Session ID updated");
                                                                } else {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Failed to update session ID");
                                                                }

                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  } else if (valueSelected ==
                                                      'delete') {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Delete Session'),
                                                          content: const Text(
                                                              'Do you want to delete this session?'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: const Text(
                                                                  'No'),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  'Yes'),
                                                              onPressed:
                                                                  () async {
                                                                bool result =
                                                                    await viewModel
                                                                        .deleteSession(
                                                                            context,
                                                                            key);
                                                                if (result) {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Deleted Successfully");
                                                                } else {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Couldn't delete this session");
                                                                }
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                itemBuilder: (BuildContext
                                                        context) =>
                                                    <PopupMenuEntry<String>>[
                                                  const PopupMenuItem<String>(
                                                    value: 'edit',
                                                    child: Text('Edit'),
                                                  ),
                                                  const PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ChatView(
                                                      isFromHistory: true,
                                                      sessionId: key,
                                                    ),
                                                  ),
                                                );
                                              },
                                              title: Text(
                                                key,
                                                style: const TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: Text('No Previous sessions'),
                                      ),
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
            ),
          ),
        );
      },
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
