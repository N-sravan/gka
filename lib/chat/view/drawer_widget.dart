import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../chat_window.dart';
import '../../utils/app_state.dart';
import '../view_model/chat_view_model.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  // late ChatViewModel viewModel;

  @override
  void initState() {
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
                                'View History',
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
                StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref(
                          "CHAT_BOT_ONDEMAND_QUERY_DATA/${constants.apwrimsUUID}/44")
                      .onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 5,
                          color: Colors.black,
                        )),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');

                    }
                    if (snapshot.hasData && snapshot.data == null) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('No Past History'),
                          ));
                    }
                    var data =
                        (snapshot.data! as DatabaseEvent).snapshot.value ?? {};
                    print("DATAFJLDLFHGLD $data");
                    data = data as Map<dynamic, dynamic>;

                    var sortedByKeyMap = Map.fromEntries(data.entries.toList()
                      ..sort((e1, e2) => e1.key.compareTo(e2.key)));
                    String sessionId = '';
                    String title = '';
                    Map<String, String> sessionTitleMapping = {};
                    sortedByKeyMap.forEach((key, value) {
                      sessionId = key;
                      if (value != null) {
                        final datalast = Map<String, dynamic>.from(value);
                        if (datalast != null) {
                          bool titleValue = false;
                          datalast.forEach((key, value) {
                            if (value['isUser'] &&
                                value['message'] != null &&
                                value['message'].isNotEmpty &&
                                !titleValue) {
                              title = value['message'];
                              titleValue = true;
                            }
                          });
                        }
                        sessionTitleMapping[sessionId] = title;
                      }
                    });
                    return Column(
                      children: generateListTiles(sessionTitleMapping),
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

  List<Widget> generateListTiles(Map<String, String> sessionTitleMapping) {
    List<Widget> listTiles = [];
    Map<String, String> data = sessionTitleMapping;
    data.forEach((key, value) {
      listTiles.add(
        ListTile(
          title: Text(value),
          onTap: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatWindow(
                  sessionId: key,
                  isFirstTime: true,
                  isFromHistory: true,
                  finishSession: (finishSession) {}, // Adjust accordingly
                ),
              ),
            );
          },
        ),
      );
    });
    return listTiles;
  }
}
