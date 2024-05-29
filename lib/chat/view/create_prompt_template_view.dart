import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';

class CreatePromptView extends StatefulWidget {
  final bool? isCreate;

  const CreatePromptView({this.isCreate, Key? key}) : super(key: key);

  @override
  State<CreatePromptView> createState() => _CreatePromptViewState();
}

class _CreatePromptViewState extends State<CreatePromptView> {
  // Define TextEditingController for the text fields

  late ChatViewModel viewModel;
  bool isCreatePrompt = false;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    if (widget.isCreate != null && widget.isCreate == true) {
      isCreatePrompt = true;
    }
  }

  @override
  void dispose() {
    viewModel.promptController.clear();
    viewModel.intentController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        if (model.isLoading) {
          return child ?? const SizedBox();
        }
        return Scaffold(
          appBar: AppBar(
              title: isCreatePrompt
                  ? const Text('Create Prompt')
                  : const Text('Update Prompt')),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Enter Prompt',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    controller: viewModel.promptController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    // Allows for unlimited lines
                    onChanged: (value) {
                      setState(() {}); // Update the UI when text changes
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Enter Intent',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    enabled: widget.isCreate,
                    controller: viewModel.intentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    // Allows for unlimited lines
                    onChanged: (value) {
                      setState(() {}); // Update the UI when text changes
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const Spacer(),
                buttonWidget(),
              ],
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

  Widget buttonWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: MaterialButton(
              onPressed: () async {
                Navigator.pop(context);
                // viewModel.updateFieldDataValue();
              },
              color: Colors.blue,
              elevation: 2,
              focusElevation: 4,
              hoverElevation: 4,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                constants.cancel,
                style: constants.white16W500,
              ),
            ),
          ),
          const SizedBox(width: 16), // Add spacing between buttons
          Expanded(
            child: MaterialButton(
              onPressed: () async {
                if (viewModel.promptController.text.isNotEmpty &&
                    viewModel.intentController.text.isNotEmpty) {
                  bool? result;
                  if (isCreatePrompt) {
                    result = await viewModel.createPrompt(
                        context,
                        viewModel.promptController.text,
                        viewModel.intentController.text);
                  } else {
                    result = await viewModel.updatePrompt(
                        context,
                        viewModel.promptController.text,
                        viewModel.intentController.text);
                  }
                  if (result) {
                    viewModel.promptController.clear();
                    viewModel.intentController.clear();
                    Navigator.pop(context);
                    await viewModel.getAvailablePrompts(
                        context, viewModel.selectedPromptModelUUID);
                    isCreatePrompt
                        ? Fluttertoast.showToast(
                        msg: "Prompt added Successfully!")
                        : Fluttertoast.showToast(
                        msg: "Prompt updated Successfully!");
                  }
                } else {
                  Fluttertoast.showToast(msg: "Please enter the data");
                }
              },
              color: Colors.blue,
              elevation: 2,
              focusElevation: 4,
              hoverElevation: 4,
              height: 40,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                constants.submit,
                style: constants.white16W500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}