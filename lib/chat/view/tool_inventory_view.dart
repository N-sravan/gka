import 'package:flutter/material.dart';
import 'package:gka/home/view_model/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;

import '../view_model/chat_view_model.dart';

class ToolInventoryView extends StatefulWidget {
  const ToolInventoryView({Key? key}) : super(key: key);

  @override
  State<ToolInventoryView> createState() => _ToolInventoryViewState();
}

class _ToolInventoryViewState extends State<ToolInventoryView> {
  String? _selectedPromptTemplate;

  late ChatViewModel viewModel;

  @override
  void initState() {
    /*   SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight, // Set landscape orientation
      DeviceOrientation.landscapeLeft,
    ]);*/
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await viewModel.getAvailableTools(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Tool Inventory'),
            ),
            body: const Center(
              child: Text('Under Development'),
            )
          ),
        );
      },
    );
  }
}
