import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/utils/app_state.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../../chat_bubble.dart';
import '../../chat_window.dart';

class NotificationsView extends StatefulWidget {
  final String? sessionId;

  const NotificationsView({Key? key, this.sessionId}) : super(key: key);

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late ChatViewModel viewModel;
  var scrollControllerListView = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.fetchNotificationData();
    });
  }

  @override
  void dispose() {
    viewModel.messageTimestampMapping.clear();
    super.dispose();
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
            viewModel.messageTimestampMapping.clear();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text('Notifications', style: constants.black16W500),
            ),
            body: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    child: viewModel.messageTimestampMapping.isNotEmpty
                        ? Column(
                            children: generateListTiles(
                                viewModel.messageTimestampMapping))
                        : const Center(child: Text('No Notifications')),
                  )),
                ],
              ),
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

  List<Widget> generateListTiles(Map<int, String> data) {
    List<Widget> listTiles = [];
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
              subtitle: Text("${key}"),
              title: const Text('APWRIMS data'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('APWRIMS summary'),
                      content: Text(value),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
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
