import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:provider/provider.dart';

class CreatePromptView extends StatefulWidget {
  const CreatePromptView({Key? key}) : super(key: key);

  @override
  State<CreatePromptView> createState() => _CreatePromptViewState();
}

class _CreatePromptViewState extends State<CreatePromptView> {
  // Define TextEditingController for the text fields
  TextEditingController promptController = TextEditingController();
  TextEditingController intentController = TextEditingController();
  late ChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
  }

  @override
  void dispose() {
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
            title: const Text('Create Prompt'),
          ),
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
                TextField(
                  controller: promptController,
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
                TextField(
                  controller: intentController,
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
                const Spacer(),
                buttonWidget(),
              ],
            ),
          ),
        );
      },
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
                // Navigator.pop(context);
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
                bool result = await viewModel.createPrompt(
                    context,
                    promptController.text,
                    intentController.text);
                if (result) {
                  promptController.clear();
                  intentController.clear();
                  Navigator.of(context).pop();
                  await viewModel.getAvailablePrompts(context,viewModel.selectedPromptModelUUID);
                  Fluttertoast.showToast(
                      msg: "Prompt added Successfully!");
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
