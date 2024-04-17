import 'package:flutter/material.dart';
import 'package:gka/home/view_model/home_view_model.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;

class PromptManagementView extends StatefulWidget {
  const PromptManagementView({Key? key}) : super(key: key);

  @override
  State<PromptManagementView> createState() => _PromptManagementViewState();
}

class _PromptManagementViewState extends State<PromptManagementView> {
  String? _selectedPromptTemplate;
  late HomeViewModel viewModel;

  @override
  void initState() {
    /*   SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight, // Set landscape orientation
      DeviceOrientation.landscapeLeft,
    ]);*/
    super.initState();
    viewModel = Provider.of<HomeViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.getAvailablePrompts(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (_, model, child) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Prompt Management'),
            ),
            body: ListView.builder(
              itemCount: viewModel.promptTemplateIntentMapping.length,
              itemBuilder: (context, index) {
                final key =
                    viewModel.promptTemplateIntentMapping.keys.elementAt(index);
                final value = viewModel.promptTemplateIntentMapping[key];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text('Prompt: $key'),
                    subtitle: Text('Intent: $value'),
                    onTap: () {
                      showDialog(
                          context: context, builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text('Update Prompt'),
                          content: const Text('Do you want to update this prompt?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Yes'),
                              onPressed: () {
                                // Implement update functionality here
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
            ),
          ),
        );
      },
    );
  }
}
