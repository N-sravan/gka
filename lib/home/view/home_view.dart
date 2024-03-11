import 'package:flutter/material.dart';
import 'package:gka/utils/common_constants.dart' as constants;

import '../../chat/view/chat_view.dart';
import '../../login/model/department_user_permission_response.dart' as response;

class HomeScreenWidget extends StatefulWidget {

  final response.Meta data;

  const HomeScreenWidget({super.key,required this.data});


  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
 late final response.Meta data;

  @override
  void initState() {
     data=widget.data;
      super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AgriBot',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
      body: ChatView(data),
    );
  }
}
