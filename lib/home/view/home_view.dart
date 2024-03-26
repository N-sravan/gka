import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../chat/view/chat_view.dart';
import '../../login/model/department_user_permission_response.dart' as response;

class HomeScreenWidget extends StatefulWidget {
  final response.Meta data;

  const HomeScreenWidget({Key? key, required this.data});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  late final response.Meta data;

  @override
  void initState() {
    data = widget.data;
 /*   SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight, // Set landscape orientation
      DeviceOrientation.landscapeLeft,
    ]);*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatView(data),
    );
  }
}
