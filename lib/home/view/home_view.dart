import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/home/view_model/home_view_model.dart';
import 'package:provider/provider.dart';
import '../../chat_window.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../../login/model/login_api_response_model.dart' as response;

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({Key? key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  late HomeViewModel viewModel;

  @override
  void initState() {
    /*   SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight, // Set landscape orientation
      DeviceOrientation.landscapeLeft,
    ]);*/
    super.initState();
    viewModel = Provider.of<HomeViewModel>(context, listen: false);
    switch (constants.projectId) {
      case constants.gowaterUUID:
        viewModel.langList.clear();
        viewModel.langList.add('English');
        viewModel.langList.add('Odia');
        break;
      case constants.apwrimsUUID:
        viewModel.langList.clear();
        viewModel.langList.add('English');
        viewModel.langList.add('Telugu');
        break;
      case constants.kaleswaramUUID:
        viewModel.langList.clear();
        viewModel.langList.add('English');
        viewModel.langList.add('Telugu');
        break;
      case constants.tnwrimsUUID:
        viewModel.langList.clear();
        viewModel.langList.add('English');
        viewModel.langList.add('Tamil');
        break;
      /*  case constants.fieldRishiUUID:
        viewModel.langList.clear();
        viewModel.langList.add('English');
        // viewModel.langList.add('Hindi');
        break;*/
    }
    /* WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await viewModel.deleteData();
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (_, model, child) {
        if (model.isLoading) {
          return child ?? const SizedBox();
        }
        return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: Text(constants.appTitle),
                actions: [
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(Icons.exit_to_app),
                            title: Text('Logout'),
                          ),
                        ),
                      ];
                    },
                    onSelected: (String value) async {
                      if (value == 'logout') {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                      /*   bool? result = await viewModel.deleteToken(context);
                        if (result != null && result) {
                          await viewModel.setLogoutSharedPreferences(context);
                          Fluttertoast.showToast(msg: "Logged out");
                          Navigator.pushReplacementNamed(context, '/login');
                        }*/
                    },
                  ),
                ],
              ),
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Select Language',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        hint: const Text('Select'),
                        items: viewModel.langList
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
                        value: viewModel.selectedLang.isNotEmpty == true
                            ? viewModel.selectedLang
                            : null,
                        onChanged: (String? value) async {
                          if (value!.isNotEmpty) {
                            viewModel.updateSelectedLanguage(value);
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
                          contentPadding: EdgeInsets.only(
                              top: 2, left: 2, right: 2, bottom: 2),
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
                    /*  const SizedBox(height: 20),
                    const Text(
                      'Select Model',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
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
                        value: viewModel.selectedModel.isNotEmpty == true
                            ? viewModel.selectedModel
                            : null,
                        onChanged: (String? value) async {
                          if (value!.isNotEmpty) {
                            viewModel.updateSelectedModel(value);
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
                          contentPadding: EdgeInsets.only(
                              top: 2, left: 2, right: 2, bottom: 2),
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
                    ),*/
                    const SizedBox(height: 20),
                    const Text(
                      'Select Mode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        hint: const Text('Select'),
                        items: viewModel.modeList!
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
                        value: viewModel.selectedMode.isNotEmpty == true
                            ? viewModel.selectedMode
                            : null,
                        onChanged: (String? value) async {
                          if (value!.isNotEmpty) {
                            viewModel.updateSelectedMode(value);
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
                          maxHeight: 300,
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
                          contentPadding: EdgeInsets.only(
                              top: 2, left: 2, right: 2, bottom: 2),
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
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (viewModel.selectedLang.isNotEmpty ||
                            viewModel.selectedModel.isNotEmpty) {
                          /*  if (viewModel.selectedLang == 'Odia') {
                            AppState.instance.isOriyaSelected = true;
                          } else {
                            AppState.instance.isOriyaSelected = false;
                          }*/
                          String? sessionId = await viewModel.createSession();
                          if (viewModel.sessionId != null &&
                              viewModel.sessionId!.isNotEmpty &&
                              sessionId != null &&
                              sessionId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatWindow(
                                  isFromHistory: false,
                                  sessionId: viewModel.sessionId!,
                                ),
                              ),
                            );
                          }
                        } else {
                          Fluttertoast.showToast(msg: 'Please select');
                        }
                      },
                      child: !model.isLoading
                          ? const Text('Start Session')
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.white,
                              child: constants.indicator,
                            ),
                    ),
                  ],
                ),
              ),
            ));
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
