import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gka/login/model/ap_data_model.dart' as apdata;
import '../../chat/view/chat_view.dart';
import '../../login/model/department_user_permission_response.dart' as response;

class HomeScreenWidget extends StatefulWidget {

  const HomeScreenWidget({Key? key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  // late final response.Meta data;
  late final apdata.UserDetailsJsonForAp data;

  @override
  void initState() {
 /*   SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight, // Set landscape orientation
      DeviceOrientation.landscapeLeft,
    ]);*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(),
    );
  }
}
