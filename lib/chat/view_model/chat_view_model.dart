import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../../login/model/department_user_permission_response.dart' as response;

class ChatViewModel extends ChangeNotifier {
  bool isFirstTime = true;
  String? sessionId;

  Future<String?> createSession(response.Meta requestData) async {
    try {
      String url = constants.ngrok;
      Object object = json.encode(requestData);
      Response response = await post(
        Uri.parse(url),
        body: object,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        print("sessionId:: ${jsonDecode(response.body)["session_id"]}");
        sessionId = jsonDecode(response.body)["session_id"];
        isFirstTime = false;
        notifyListeners();
        return sessionId;
      } else {
        Fluttertoast.showToast(msg: "Couldn't create Session");
      }
    } catch (error, stacktrace) {
      Fluttertoast.showToast(msg: "Couldn't create Session");
      print("Error Stacktrace $error $stacktrace");
    }
    return null;
  }

  void updateFirstTimeValue() {
    isFirstTime = true;
    notifyListeners();
  }
}
