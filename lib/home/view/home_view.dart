import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/home/view_model/home_view_model.dart';
import 'package:gka/utils/app_state.dart';
import 'package:provider/provider.dart';
import '../../chat/view/chat_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.getAvailableModels(context);
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
                title: const Text('GoWater Bot'),
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

                     /*   bool? result = await viewModel.deleteToken(context);
                        if (result != null && result) {
                          await viewModel.setLogoutSharedPreferences(context);
                          Fluttertoast.showToast(msg: "Logged out");
                          Navigator.pushReplacementNamed(context, '/login');
                        }*/
                      }
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
                      width: MediaQuery.of(context).size.width * 0.7,
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
                    const SizedBox(height: 20),
                    const Text(
                      'Select Model',
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
                            // setState(() {
                            //   selectedValue = value;
                            // });
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
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        if (viewModel.selectedLang.isNotEmpty ||
                            viewModel.selectedModel.isNotEmpty) {
                          if (viewModel.selectedLang == 'Odia') {
                            AppState.instance.isOriyaSelected = true;
                          } else {
                            AppState.instance.isOriyaSelected = false;
                          }

                          String? sessionId = await viewModel.createSession();
                          if (viewModel.sessionId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatWindow(
                                  isFromHistory: false,
                                  isFirstTime: viewModel.isFirstTime,
                                  finishSession: (bool finishSession) {
                                    if (finishSession) {
                                      viewModel.updateFirstTimeValue();
                                    }
                                  },
                                  sessionId: viewModel.sessionId!,
                                ),
                              ),
                            );
                          }
                        } else {
                          Fluttertoast.showToast(msg: 'Please select');
                        }
                      },
                      child: const Text('Start Session'),
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

class PaddedElevatedButton extends StatelessWidget {
  const PaddedElevatedButton({
    required this.buttonText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
    child: ElevatedButton(
      onPressed: onPressed,
      child: Text(buttonText),
    ),
  );
}

String? selectedNotificationPayload;

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

Future<void> _showNotificationWithActions() async {
  const AndroidNotificationDetails androidNotificationDetails =
  AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        urlLaunchActionId,
        'Action 1',
        icon: DrawableResourceAndroidBitmap('food'),
        contextual: true,
      ),
      AndroidNotificationAction(
        'id_2',
        'Action 2',
        titleColor: Color.fromARGB(255, 255, 0, 0),
        icon: DrawableResourceAndroidBitmap('secondary_icon'),
      ),
      AndroidNotificationAction(
        navigationActionId,
        'Action 3',
        icon: DrawableResourceAndroidBitmap('secondary_icon'),
        showsUserInterface: true,
        // By default, Android plugin will dismiss the notification when the
        // user tapped on a action (this mimics the behavior on iOS).
        cancelNotification: false,
      ),
    ],
  );

  // const DarwinNotificationDetails iosNotificationDetails =
  // DarwinNotificationDetails(
  //   categoryIdentifier: darwinNotificationCategoryPlain,
  // );
  //
  // const DarwinNotificationDetails macOSNotificationDetails =
  // DarwinNotificationDetails(
  //   categoryIdentifier: darwinNotificationCategoryPlain,
  // );

  // const LinuxNotificationDetails linuxNotificationDetails =
  // LinuxNotificationDetails(
  //   actions: <LinuxNotificationAction>[
  //     LinuxNotificationAction(
  //       key: urlLaunchActionId,
  //       label: 'Action 1',
  //     ),
  //     LinuxNotificationAction(
  //       key: navigationActionId,
  //       label: 'Action 2',
  //     ),
  //   ],
  // );
  //
  // const NotificationDetails notificationDetails = NotificationDetails(
  //   android: androidNotificationDetails,
  //   iOS: iosNotificationDetails,
  //   macOS: macOSNotificationDetails,
  //   linux: linuxNotificationDetails,
  // );
  // await flutterLocalNotificationsPlugin.show(
  //     id++, 'plain title', 'plain body', notificationDetails,
  //     payload: 'item z');
}