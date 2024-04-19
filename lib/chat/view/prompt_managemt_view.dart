import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/view/create_prompt_template.dart';
import 'package:provider/provider.dart';
import '../../utils/app_state.dart';
import '../view_model/chat_view_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/common_constants.dart' as constants;

class PromptManagementView extends StatefulWidget {
  const PromptManagementView({Key? key}) : super(key: key);

  @override
  State<PromptManagementView> createState() => _PromptManagementViewState();
}

class _PromptManagementViewState extends State<PromptManagementView> {
  String? _selectedPromptTemplate;
  String? _selectedPromptKey;
  TextEditingController _promptTextController = TextEditingController();

  late ChatViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<ChatViewModel>(context, listen: false);
    viewModel.selectedPromptModelUUID = AppState.instance.modelUUID;
    viewModel.selectedPromptModel = AppState.instance.modelName;
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await viewModel.getAvailablePrompts(
          context, viewModel.selectedPromptModelUUID);
      await viewModel.getAvailableModels(context);
    });
  }

  @override
  void dispose() {
    _promptTextController.clear();
    viewModel.clearData();
    super.dispose();
  }

  void _createPrompt() {
    String newPrompt = _promptTextController.text;
    if (newPrompt.isNotEmpty) {
      setState(() {
        viewModel.promptTemplateIntentMapping[newPrompt] = "New Intent";
      });
      _promptTextController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (_, model, child) {
        /* if (model.isLoading) {
          return child ?? const SizedBox();
        }*/
        return WillPopScope(
          onWillPop: () {
            viewModel.clearData();
            return Future.value(true);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Prompt Management'),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Select Model',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField2<String>(
                    isExpanded: true,
                    hint: const Text('Select'),
                    items: viewModel.modelList!
                        .map((String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ))
                        .toList(),
                    value: viewModel.selectedPromptModel.isNotEmpty == true
                        ? viewModel.selectedPromptModel
                        : null,
                    onChanged: (String? value) async {
                      if (value!.isNotEmpty) {
                        await viewModel.updateSelectedModelForPrompt(value);
                        await viewModel.getAvailablePrompts(
                            context, viewModel.selectedPromptModelUUID);
                      }
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(118, 118, 128, 0.12),
                        boxShadow: const [],
                      ),
                      elevation: 0,
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                      ),
                      iconSize: 20,
                      iconEnabledColor: Color(0xFF666B77),
                      iconDisabledColor: Color(0xFF666B77),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.grey.shade300,
                        boxShadow: const [],
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 30,
                      padding: EdgeInsets.only(left: 14, right: 14),
                    ),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: 'Select',
                      hintStyle: TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                      contentPadding:
                          EdgeInsets.only(top: 2, left: 2, right: 2, bottom: 2),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      errorStyle: TextStyle(
                        color: Colors.red,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Create a Prompt'),
                  trailing: const Icon(Icons.add),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatePromptView(
                                isCreate: true,
                              )),
                    ); /* showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        _promptTextController.clear();
                        return AlertDialog(
                          title: const Text('Create Prompt'),
                          content: TextField(
                            controller: _promptTextController,
                            decoration: const InputDecoration(
                                labelText: 'Enter your prompt'),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Submit'),
                              onPressed: () async {
                                bool result = await viewModel.createPrompt(
                                    context,
                                    _promptTextController.text,
                                    'zero-shot');
                                if (result) {
                                  _promptTextController.clear();
                                  Navigator.of(context).pop();
                                  await viewModel.getAvailablePrompts(context);
                                  Fluttertoast.showToast(
                                      msg: "Prompt added Successfully!");
                                }
                                // _createPrompt();
                              },
                            ),
                          ],
                        );
                      },
                    );*/
                  },
                ),
                viewModel.promptTemplateIntentMapping.isNotEmpty
                    ? Expanded(
                        child: !model.isLoading
                            ? ListView.builder(
                                itemCount: viewModel
                                    .promptTemplateIntentMapping.length,
                                itemBuilder: (context, index) {
                                  final key = viewModel
                                      .promptTemplateIntentMapping.keys
                                      .elementAt(index);
                                  final value = viewModel
                                      .promptTemplateIntentMapping[key];
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
                                                      'Delete Prompt'),
                                                  content: const Text(
                                                    'Do you want to delete this prompt?',
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
                                                        // Implement delete logic here
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
                                      title: Text('Prompt: $key'),
                                      subtitle: Text('Intent: $value'),
                                      onTap: () {
                                        setState(() {
                                          _selectedPromptKey = key;
                                          _promptTextController.text = key;
                                        });
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => CreatePromptView(isCreate: false,)),
                                        );
                                      /*  showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Update Prompt'),
                                              content: TextField(
                                                controller:
                                                    _promptTextController,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText:
                                                      'Enter your prompt',
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Back'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Submit'),
                                                  onPressed: () async {
                                                    bool result = await viewModel
                                                        .updatePrompt(
                                                            context,
                                                            _promptTextController
                                                                .text,
                                                            'zero-shot');
                                                    if (result) {
                                                      _promptTextController
                                                          .clear();
                                                      Navigator.of(context)
                                                          .pop();
                                                      await viewModel
                                                          .getAvailablePrompts(
                                                              context,
                                                              viewModel
                                                                  .selectedPromptModelUUID);
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Prompt Updated Successfully!");
                                                    }
                                                    // _createPrompt();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );*/
                                      },
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                color: Colors.white,
                                child: constants.indicator,
                              ),
                      )
                    : const Expanded(
                        child: Center(
                          child: Text('No Prompts found'),
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
}
