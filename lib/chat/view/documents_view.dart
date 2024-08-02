import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/model/get_documents_response.dart';
import 'package:gka/chat/view/chunks_view.dart';
import 'package:gka/chat/view/upload_document_view.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import '../view_model/chat_view_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'create_prompt_template_view.dart';

class DocumentsView extends StatefulWidget {
  const DocumentsView({Key? key}) : super(key: key);

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

class _DocumentsViewState extends State<DocumentsView> {
  TextEditingController _promptTextController = TextEditingController();

  late ChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.getDocuments(context);
    });
  }

  @override
  void dispose() {
    _promptTextController.clear();
    viewModel.clearData();
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
          onWillPop: () {
            viewModel.clearData();
            return Future.value(true);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Documents'),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text(
                    'Upload a document',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.upload,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UploadDocumentView()),
                    );
                  },
                ),
                viewModel.documentIdTextMapping.isNotEmpty
                    ? Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ListView.builder(
                              itemCount: viewModel.documentIdTextMapping.length,
                              itemBuilder: (context, index) {
                                final key = viewModel.documentIdTextMapping.keys
                                    .elementAt(index);
                                final value =
                                    viewModel.documentIdTextMapping[key];
                                final admin = value![0].userDetails!.name;
                                final phone = value![0].userDetails!.phone;
                                final date = value![0].uploadedDate;
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: ListTile(
                                    trailing: IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Delete Document'),
                                                content: const Text(
                                                  'Do you want to delete this file?',
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: const Text('No'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: const Text('Yes'),
                                                    onPressed: () async {
                                                      bool result =
                                                          await viewModel
                                                              .deleteDocument(
                                                                  context,
                                                                  viewModel
                                                                      .fileUUID);
                                                      if (result) {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Deleted Successfully");
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                "Couldn't delete this file");
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 20,
                                      ),
                                    ),
                                    title: RichText(
                                      text: TextSpan(
                                        text: 'File Name - ',
                                        style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: key,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              text: 'Admin - ',
                                              style: const TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: admin,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 4.0), // Add spacing
                                          RichText(
                                            text: TextSpan(
                                              text: 'Uploaded Date - ',
                                              style: const TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: date,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 4.0), // Add spacing
                                          RichText(
                                            text: TextSpan(
                                              text: 'Phone - ',
                                              style: const TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.black),
                                              children: [
                                                TextSpan(
                                                  text: phone,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DocumentsChunkView(
                                                  chunksData: value),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            )))
                    : const Expanded(
                        child: Center(
                          child: Text('No Documents found'),
                        ),
                      ),
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

  String getFirstLines(String? text, int lineCount) {
    if (text == null) return 'No content available';
    List<String> lines = text.split('\n');
    return lines.take(lineCount).join('\n');
  }
}
