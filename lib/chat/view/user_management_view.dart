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

class UserManagementView extends StatefulWidget {
  const UserManagementView({Key? key}) : super(key: key);

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  late ChatViewModel viewModel;
  Map<int, bool> showTextFieldMap = {};
  Map<int, TextEditingController> textFieldControllers = {};
  Map<int, String?> activityStatusMap = {};
  bool isIncreased = false;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.getUsersList(context);
    });
  }

  @override
  void dispose() {
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
              title: const Text('User Management'),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                viewModel.usersList.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListView.builder(
                            itemCount: viewModel.usersList.length,
                            itemBuilder: (context, index) {
                              final user = viewModel.usersList[index];
                              final name = user.name;
                              final phone = user.phone ?? '';
                              final address = user.address;
                              final tokenStatus = user.tokenStatus;
                              showTextFieldMap[index] =
                                  showTextFieldMap[index] ?? false;
                              textFieldControllers[index] =
                                  textFieldControllers[index] ??
                                      TextEditingController();
                              activityStatusMap[index] =
                                  activityStatusMap[index] ?? user.userStatus;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  title: RichText(
                                    text: TextSpan(
                                      text: '$name   ',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: phone,
                                          style: const TextStyle(
                                              fontSize: 14.0,
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
                                            text: '$address',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        RichText(
                                          text: TextSpan(
                                            text: 'Token status - ',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '$tokenStatus',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                            height: 4.0), // Add spacing
                                        StatefulBuilder(
                                          builder: (BuildContext context,
                                              StateSetter setState) {
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    DropdownButton<String>(
                                                      value: activityStatusMap[
                                                          index],
                                                      items: <String>[
                                                        'active',
                                                        'inactive'
                                                      ].map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(
                                                            value,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          activityStatusMap[
                                                                  index] =
                                                              newValue!;
                                                        });
                                                      },
                                                    ),
                                                    const SizedBox(width: 20),
                                                    IconButton(
                                                      icon:
                                                          const Icon(Icons.add),
                                                      onPressed: () {
                                                        setState(() {
                                                          showTextFieldMap[
                                                                  index] =
                                                              !showTextFieldMap[
                                                                  index]!;
                                                          isIncreased = true;
                                                        });
                                                      },
                                                    ),
                                                    const SizedBox(width: 20),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.remove),
                                                      onPressed: () {
                                                        setState(() {
                                                          showTextFieldMap[
                                                                  index] =
                                                              !showTextFieldMap[
                                                                  index]!;
                                                          isIncreased = false;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                if (showTextFieldMap[index]!)
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          width: 10.0,
                                                          // height: 50.0,
                                                          child: TextField(
                                                            controller:
                                                                textFieldControllers[
                                                                    index],
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Enter limit',
                                                              hintStyle:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontSize: 12,
                                                              ),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0), // Circular border radius
                                                              ),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8.0,
                                                                      horizontal:
                                                                          12.0), // Adjust internal padding
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          bool? result = await viewModel.submitActivityStatus(context, textFieldControllers[index]!.text,isIncreased);
                                                          if (result != null &&
                                                              result == true) {
                                                            Fluttertoast.showToast(msg: 'Updated Successfully!');
                                                            await viewModel
                                                                .getUsersList(
                                                                    context);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Submit'),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : const Expanded(
                        child: Center(
                          child: Text('No data found'),
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
