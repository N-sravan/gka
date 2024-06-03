import 'package:flutter/material.dart';
import 'package:gka/chat/view/prompt_management_view.dart';
import 'package:gka/chat/view/tool_inventory_view.dart';
import 'package:gka/utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import 'chat_history_view.dart';
import 'documents_view.dart';
import 'notifications_view.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late String mode;
  late bool isDisplay;

  // late ChatViewModel viewModel;

  @override
  void initState() {
    mode = AppState.instance.mode;
    if (mode.isNotEmpty) {
      if (mode == 'data_interaction_chat') {
        isDisplay = true;
      } else {
        isDisplay = false;
      }
    }
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
                      color: Colors.black,
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
                                'Hello', // Changed "View History" to "Hello"
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
                    children: [
                      Text(
                        "Notifications",
                        style: constants.appBarListTileTextStyle,
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications), // Icon for "View History"
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
                isDisplay
                    ? ListTile(
                        title: Row(
                          children: [
                            Text(
                              "Documents",
                              style: constants.appBarListTileTextStyle,
                            ),
                            const Spacer(),
                            const Icon(Icons.upload_file),
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
                /*ListTile(
                  title: Row(
                    children: [
                      Text(
                        "View History",
                        style: constants.appBarListTileTextStyle,
                      ),
                      const Spacer(),
                      const Icon(Icons.history), // Icon for "View History"
                    ],
                  ),
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatHistoryView(),
                      ),
                    );
                  },
                ),*/
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        "Prompt Management",
                        style: constants.appBarListTileTextStyle,
                      ),
                      const Spacer(),
                      const Icon(Icons.manage_accounts),
                      // Icon for "Prompt Management"
                    ],
                  ),
                  onTap: () {
                    // Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PromptManagementView(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        "Tool Inventory",
                        style: constants.appBarListTileTextStyle,
                      ),
                      const Spacer(),
                      const Icon(Icons.inventory), // Icon for "Tool Inventory"
                    ],
                  ),
                  onTap: () {
                    // Fluttertoast.showToast(msg: "Under Development");
                    // Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ToolInventoryView(),
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
          )
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
