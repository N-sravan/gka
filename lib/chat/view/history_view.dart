import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/utils/app_state.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../../chat_bubble.dart';
import '../../chat_window.dart';

class ChatHistoryView extends StatefulWidget {
  String? sessionId;

  ChatHistoryView({Key? key, this.sessionId}) : super(key: key);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title:  Text(
                  'Chat History',
                  style: constants.black16W500
              ),
            ),
            body: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: StreamBuilder(
                        stream: FirebaseDatabase.instance
                            .ref(
                            "CHAT_BOT_ONDEMAND_QUERY_DATA/${constants.apwrimsUUID}/${AppState.instance.userId}")
                            .onValue,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(120.0),
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
                              (snapshot.data! as DatabaseEvent).snapshot.value ??
                                  {};
                          print("DATAFJLDLFHGLD $data");
                          data = data as Map<dynamic, dynamic>;

                          var sortedByKeyMap = Map.fromEntries(
                              data.entries.toList()
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

  List<Widget> generateListTiles(Map<String, String> sessionTitleMapping) {
    List<Widget> listTiles = [];
    Map<String, String> data = sessionTitleMapping;
    data.forEach((key, value) {
      listTiles.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              /*   boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],*/
            ),
            child: ListTile(
              title: Text(value),
              onTap: () {
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
          ),
        ),
      );
    });
    return listTiles;
  }
}