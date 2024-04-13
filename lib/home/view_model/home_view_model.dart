import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/view/chat_view.dart';
import 'package:gka/home/repository/home_repo.dart';
import 'package:gka/login/model/login_api_response_model.dart';
import 'package:gka/shared/loading_view_model.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:fluttertoast/fluttertoast.dart';
import '../../login/view/login_view.dart';
import '../../utils/app_state.dart';
import '../../utils/network_utils.dart';
import '../../utils/secure_storage_util.dart';
import '../../utils/util.dart';

class HomeViewModel extends LoadingViewModel {
  HomeViewModel({
    required this.repo,
  });

  final HomeRepository repo;

  String selectedValue = '';
  String selectedLang = '';
  List<String> selectionList = ['Internal LLM', 'External LLM'];
  List<String> langList = ['English','Telugu'];


  final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
  StreamController<ReceivedNotification>.broadcast();

  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();

  void updateSelectedValue(String value) {
    selectedValue = value;
    notifyListeners();
  }

  void updateSelectedLanguage(String value) {
    selectedLang = value;
    notifyListeners();
  }

  setLogoutSharedPreferences(BuildContext context) async {
    await SecuredStorageUtil.instance.deleteAllSecureData();
    AppState.instance.userName = '';
    AppState.instance.userData = '';
    AppState.instance.userId = '';
    AppState.instance.locType = '';
    AppState.instance.locUUID = '';
    AppState.instance.locName = '';
    AppState.instance.fcmToken = '';
    AppState.instance.isTeluguSelected = false;
    notifyListeners();
  }

  Future<bool?> deleteToken(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        int? statusCode = await repo.deleteToken(context);

        if (statusCode != null) {
          if (statusCode == 200) {
            isLoading = false;
            notifyListeners();
            return true;
          } else {
            isLoading = false;
            notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong,Please try later'),
            ));
          }
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return null;
  }

   configureDidReceiveLocalNotificationSubject(BuildContext context) {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) =>
            CupertinoAlertDialog(
              title: receivedNotification.title != null
                  ? Text(receivedNotification.title!)
                  : null,
              content: receivedNotification.body != null
                  ? Text(receivedNotification.body!)
                  : null,
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreenWidget()),
                    );
                   /* await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ChatView(receivedNotification.payload),
                            ChatView(receivedNotification.payload),
                      ),
                    );*/
                  },
                  child: const Text('Ok'),
                )
              ],
            ),
      );
    });
  }

   configureSelectNotificationSubject(BuildContext context) {
    selectNotificationStream.stream.listen((String? payload) async {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenWidget()),
      );
     /* await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => ChatView(payload),
      ));*/
    });
  }


}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
