import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/chat_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gka/login/repository/login_repo.dart';
import 'package:gka/login/view/login_view.dart';
import 'package:gka/login/view_model/login_view_model.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;
import 'dart:io' as platform;

import 'locator.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
var initializationSettingsAndroid = const AndroidInitializationSettings(
    '@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
var initializationSettingsIOS = const DarwinInitializationSettings();
var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
SpeechToText speechToText = SpeechToText();
ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);
ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
TextToSpeech tts = TextToSpeech();
int response = 1;
bool speechEnabled = false;
bool shouldListen = true;
String bgChatSessionId = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();

  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyD4kQrxxhyhqQwRjhnKRVJPgpT9jkuadUo',
    appId: '1:1062998944432:ios:597dab286cd6fc12f22975',
    messagingSenderId: '1062998944432',
    projectId: 'apwrims---chatbot',
    storageBucket: 'apwrims---chatbot.appspot.com',
    iosBundleId: 'com.vassar.apwrimschatbot',
  ));

  setupLocator();
  // await initializeService();


  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  /* Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "speechTask",
    "speechTask",
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 2),
  );*/
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(repo: locator<LoginRepository>()),
      ),
      ChangeNotifierProvider(
        create: (_) => ChatViewModel(),
      ),
    ],
      child: const MyApp(),
    ),
  );
}

Future<void> requestPermissions() async {
  await Permission.microphone.request();
  await Permission.notification.request();
}

void callbackDispatcher() {
  /*
  Workmanager().executeTask((task, inputData) async {
    if (task == 'speechTask') {
      print("222222-Background task executed");
      final receivePort = ReceivePort();
      await Isolate.spawn(
          complexTask3, {'iteration': 1, 'sendPort': receivePort.sendPort});
      receivePort.listen((total) async {
        // await showNotification();
        await speakText("Tell a command to proceed");
        bgChatSessionId = const Uuid().v4().toString();
        await initializeSpeechToText();
      });
    }
    return Future.delayed(const Duration(minutes: 20), () async {
      return Future.value(true);
    });
  });*/
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'test',
    'test',
    platformChannelSpecifics,
  );
}

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

speakText(String text) async {
  print("Speak text");
  try {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    flutterTts.errorHandler = (error) {
      print("An error occurred: $error");
    };
    await flutterTts.speak(text);
  } catch (e) {
    print("ERROR FOR speakText() $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChatBot Weather',
        // home: const MyHomePage(title: 'ChatBot Weather'),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreenWidget(),
        },
      ),
    );
  }
}