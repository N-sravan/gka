import 'package:flutter/material.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:path/path.dart' as path;
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:provider/provider.dart';

class UploadDocumentView extends StatefulWidget {
  const UploadDocumentView({Key? key}) : super(key: key);

  @override
  State<UploadDocumentView> createState() => _UploadDocumentViewState();
}

class _UploadDocumentViewState extends State<UploadDocumentView> {
  late ChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      /* await viewModel.getAvailablePrompts(context, viewModel.selectedPromptModelUUID);
      await viewModel.getAvailableModels(context);*/
    });
  }

  @override
  void dispose() {
    viewModel.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(builder: (_, model, child) {
      return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Upload Document'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: viewModel.pickFile,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Pick File'),
                    ),
                  ],
                ),
                if (viewModel.selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, color: Colors.green),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(
                                    'File selected: ${path.basename(viewModel.selectedFile!.path)}')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (!viewModel.isUploading) {
                              bool result = await viewModel.uploadFile(context);
                              print("wewewew result upload file ::${result}");
                              if (result) {
                                await viewModel.getDocuments(context);
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: viewModel.isUploading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text('Upload File'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        onWillPop: () {
          viewModel.clearData();
          return Future.value(true);
        },
      );
    });
  }
}
