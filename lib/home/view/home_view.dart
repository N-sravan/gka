import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/app_state.dart';
import '../../chat/view/chat_view.dart';
import '../../login/model/login_api_response_model.dart' as response;

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({Key? key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  // late final response.Meta data;
  String selectedValue = '';
  String selectedLang = '';
  List<String> selectionList = ['Internal LLM', 'External LLM'];
  List<String> langList = ['Telugu', 'English'];

  @override
  void initState() {
    /*   SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight, // Set landscape orientation
      DeviceOrientation.landscapeLeft,
    ]);*/
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    selectedValue = '';
    selectedLang = '';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          selectedValue = '';
          selectedLang = '';
          return Future.value(true);
        },
        child: Scaffold(
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select LLM Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField2<String>(
                    isExpanded: true,
                    hint: const Text('Select'),
                    items: selectionList
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
                    value:
                        selectedValue.isNotEmpty == true ? selectedValue : null,
                    onChanged: (String? value) async {
                      if (value!.isNotEmpty) {
                        setState(() {
                          selectedValue = value;
                        });
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
                const SizedBox(height: 20),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField2<String>(
                    isExpanded: true,
                    hint: const Text('Select'),
                    items: langList
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
                    value:
                        selectedLang.isNotEmpty == true ? selectedLang : null,
                    onChanged: (String? value) async {
                      if (value!.isNotEmpty) {
                        setState(() {
                          selectedLang = value;
                        });
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (selectedValue.isNotEmpty && selectedLang.isNotEmpty) {
                      if (selectedValue == 'External LLM') {
                        AppState.instance.isExternalLLM = true;
                      } else {
                        AppState.instance.isExternalLLM = false;
                      }

                      if (selectedLang == 'Telugu') {
                        AppState.instance.isTeluguSelected = true;
                      } else {
                        AppState.instance.isTeluguSelected = false;
                      }
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ChatView()));
                    } else {
                      Fluttertoast.showToast(msg: 'Please select');
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ));
  }
}
