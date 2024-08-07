import 'dart:async';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../login/model/department_user_permission_response.dart' as response;
import '../../../utils/common_constants.dart' as constants;
import '../../home/view/home_view.dart';
import '../../main.dart';
import '../../utils/app_state.dart';
import '../../utils/shared_preference_util.dart';
import '../view_model/permissions_view_model.dart';

class PermissionsScreenWidget extends StatefulWidget {
  final response.Meta data;

  const PermissionsScreenWidget({Key? key, required this.data})
      : super(key: key);

  @override
  State<PermissionsScreenWidget> createState() =>
      _PermissionsScreenWidgetState();
}

class _PermissionsScreenWidgetState extends State<PermissionsScreenWidget> {
  late PermissionsViewModel viewModel;
  late final response.Meta data;

  @override
  void initState() {
    data = widget.data;
    viewModel = Provider.of<PermissionsViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Permission.notification.request();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionsViewModel>(builder: (_, model, child) {
      return SafeArea(
          child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('Permissions'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notification Permission',
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () async {
                          await Permission.notification.request();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Voice Updates Permission',
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.audiotrack),
                        onPressed: () {
                          showVoicePermissionDialog(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 400),
            ElevatedButton(
              onPressed: () {
                /* Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreenWidget(data: widget.data)));*/
              },
              child: Text('Continue'),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ));
    });
  }

  Future<void> showVoicePermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hourly Updates'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Allow voice updates for the app?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Don\'t allow'),
            ),
            TextButton(
              onPressed: () async {
                await SharedPreferenceUtil.instance.setPreferenceValue(
                    'isVoiceEnabled', true, constants.preferenceTypeBool);
                bool value = await SharedPreferenceUtil.instance
                    .getBoolPreference('isVoiceEnabled');
                print("wewewewewew permission view isVoiceEnabled::$value");
                Navigator.of(context).pop();
                // startWorkManager();
              },
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
  }

 /* void startWorkManager() {
    print("wewewewewewew startWorkManager");
    Workmanager().registerPeriodicTask(
      "speechTask",
      "speechTask",
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 2),
    );
  }*/

/*
  callbackDispatcher() {
    Workmanager().executeTask((
      task,
      inputData,
    ) async {
      if (task == 'speechTask') {
        final receivePort = ReceivePort();
        await Isolate.spawn(
            complexTask3, {'iteration': 1, 'sendPort': receivePort.sendPort});
        receivePort.listen((total) async {
          print("wewewewewew started bg");
          await tts.speak("Would you like to know the APWRIMS Data?");
          print("wewewewewew before timer ${DateTime.now().second}");
          Timer(const Duration(seconds: 3), () async {
            try {
              print("wewewewewew after timer ${DateTime.now().second}");
              await initializeSpeechToTextBg();
            } catch (e) {
              print("Error occurred: $e");
            }
          });
        });
      }
      return Future.delayed(const Duration(seconds: 20), () async {
        return Future.value(true);
      });
    });
  }
*/

  void complexTask3(Map<String, dynamic> data) {
    print("complex task 3 started");
    var iteration = data['iteration'] as int;
    var sendPort = data['sendPort'] as SendPort;
    print("complex task 3 running");
    var total = 0.0;
    for (var i = 0; i < iteration; i++) {
      total += i;
    }
    sendPort.send(total);
    print("complex task 3 ended");
  }

  Future<void> initializeSpeechToTextBg() async {
    print(("startListeningToHello: starting listening"));
    await Firebase.initializeApp(
        options: const FirebaseOptions(
      apiKey: 'AIzaSyD4kQrxxhyhqQwRjhnKRVJPgpT9jkuadUo',
      appId: '1:1062998944432:ios:597dab286cd6fc12f22975',
      messagingSenderId: '1062998944432',
      projectId: 'apwrims---chatbot',
      storageBucket: 'apwrims---chatbot.appspot.com',
      iosBundleId: 'com.vassar.apwrimschatbot',
    ));

    bool available = await speechToText.initialize(
      onStatus: (status) async {
        print('Status: $status');
        /*  if (status == 'notListening') {
        await startListeningBg();
      }*/
      },
      onError: (error) async {
        print('Error: $error');
        // await startListeningBg();
      },
    );
    print("wewewewewew available $available");
    if (available) {
      startListeningBg();
    }
  }
}
