import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/model/get_documents_response.dart';
import 'package:gka/chat/view/upload_document_view.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import '../view_model/chat_view_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'create_prompt_template_view.dart';

class DocumentsChunkView extends StatefulWidget {
  DocumentsChunkView({Key? key, this.chunksData}) : super(key: key);

  final List<FileResponse>? chunksData;

  @override
  State<DocumentsChunkView> createState() => _DocumentsChunkViewState();
}

class _DocumentsChunkViewState extends State<DocumentsChunkView> {
  TextEditingController _promptTextController = TextEditingController();

  late ChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
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
                widget.chunksData!.isNotEmpty
                    ? Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ListView.builder(
                              itemCount: widget.chunksData?.length,
                              itemBuilder: (context, index) {
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
                                                          await viewModel.deleteChunk(context, widget.chunksData![index].chunkUUID.toString()!);
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
                                    // title: Text(getFirstLines(widget.chunksData![index].text, 2),style: TextStyle(fontSize: 10),),
                                    title: Text(
                                      widget.chunksData![index].text!,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Content'),
                                              content: SingleChildScrollView(
                                                child: Text(widget
                                                    .chunksData![index].text!),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Close'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          });
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
