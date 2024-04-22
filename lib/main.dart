import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gka/chat/repo/chat_repo.dart';
import 'package:gka/chat/view/create_prompt_template.dart';
import 'package:gka/home/repository/home_repo.dart';
import 'package:gka/home/view/home_view.dart';
import 'package:gka/home/view_model/home_view_model.dart';
import 'package:gka/utils/app_state.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:gka/utils/shared_preference_util.dart';
import 'package:gka/utils/util.dart';
import 'package:http/http.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/chat_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gka/login/repository/login_repo.dart';
import 'package:gka/login/view/login_view.dart';
import 'package:gka/login/view_model/login_view_model.dart';
import 'package:gka/permissions/view/permissions_view.dart';
import 'package:gka/permissions/view_model/permissions_view_model.dart';
import 'package:gka/splash/view/splash_view.dart';
import 'package:gka/splash/view_model/splash_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import '../../login/model/department_user_permission_response.dart' as response;
import 'dart:developer' as developer;
import 'dart:io' as platform;
import 'chat_bubble.dart';
import 'helpers/notification_helper.dart';
import 'chat/view/prompt_managemt_view.dart';
import 'chat/view/tool_inventory_view.dart';
import 'locator.dart';

var initializationSettingsAndroid = const AndroidInitializationSettings(
    '@mipmap/ic_launcher'); // <- default icon name is @mipmap/ic_launcher
var initializationSettingsIOS = const DarwinInitializationSettings();
var initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
SpeechToText speechToText = SpeechToText();
ValueNotifier<bool> listeningActive = ValueNotifier<bool>(false);
ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
ValueNotifier<bool> speakCompleted = ValueNotifier<bool>(true);
FlutterTts tts = FlutterTts();
Completer<void> ttsCompleter = Completer<void>();
// int response = 1;
bool speechEnabled = false;
bool shouldListen = true;
bool isListening = false;
String bgChatSessionId = '';
int prevChatLength = 0;
const String navigationActionId = 'id_3';
// String AppState.instance.triggeredWord = "";
PermissionStatus? notificationStatus;

ValueNotifier<SpeechStatus> speechStatus =
    ValueNotifier<SpeechStatus>(SpeechStatus.idle);

enum SpeechStatus { listening, speaking, idle }

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

String? selectedNotificationPayload;

bool? isVoiceEnabled;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();

  /*  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight, // Set landscape orientation
    DeviceOrientation.landscapeLeft,
  ]);*/

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

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
/*  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight, // Set landscape orientation
    DeviceOrientation.landscapeLeft,
  ]);*/

  NotificationHelper.initializeNotification(myBackgroundMessageHandler);

  if (notificationStatus == PermissionStatus.granted) {
    print("wewewewewew notificationStatus:::${PermissionStatus.granted}");
    Workmanager().initialize(callbackDispatcher);
    Workmanager().registerPeriodicTask(
      "speechTask",
      "speechTask",
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 2),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(repo: locator<LoginRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(repo: locator<ChatRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => SplashViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => PermissionsViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(repo: locator<HomeRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
  // await initializeService();
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<bool> requestPermissions() async {
  // Request notification permission
  final microphoneStatus = await Permission.microphone.request();
  notificationStatus = await Permission.notification.request();

  // Check if both permissions are granted
  if (microphoneStatus == PermissionStatus.granted &&
      notificationStatus == PermissionStatus.granted) {
    return true;
  } else {
    return false;
  }
}

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
        await showNotification();
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
    return Future.delayed(const Duration(minutes: 2), () async {
      return Future.value(true);
    });
  });
}

Future<void> showNotification() async {
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyD4kQrxxhyhqQwRjhnKRVJPgpT9jkuadUo',
    appId: '1:1062998944432:ios:597dab286cd6fc12f22975',
    messagingSenderId: '1062998944432',
    projectId: 'apwrims---chatbot',
    storageBucket: 'apwrims---chatbot.appspot.com',
    iosBundleId: 'com.vassar.apwrimschatbot',
  ));
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("CHAT_BOT_ALERT/HOURLY_NOTIFICATION/${constants.apwrimsUUID}");
  String responseMessage = '';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = '/splash';
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
    initialRoute = '/home';
  }

  if (platform.Platform.isAndroid) {
    // await flutterLocalNotificationsPlugin.initialize(
    //   const InitializationSettings(
    //     iOS: DarwinInitializationSettings(),
    //     android: AndroidInitializationSettings('ic_bg_service_small'),
    //   ),
    // );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

/*  final BigTextStyleInformation bigTextStyleInformation =
      const BigTextStyleInformation(
    'Tap to view details',
    htmlFormatBigText: true,
    htmlFormatContentTitle: true,
    htmlFormatSummaryText: true,
  );*/

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
          'high_importance_channel', 'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          styleInformation: BigTextStyleInformation(''));
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await ref.orderByKey().limitToLast(1).once().then((event) async {
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value != null) {
      dynamic values = snapshot.value;
      values.forEach((key, value) async {
        if (value['isUser'] == false) {
          responseMessage = value['message'].toString() ?? '';
        }
      });
    }
  });
  print("wewewewewew::$responseMessage");

  if (responseMessage.isNotEmpty) {
    await flutterLocalNotificationsPlugin.show(0, 'APWRIMS Summary',
        responseMessage.toString().trim(), platformChannelSpecifics);
  }
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
  if (available) {
    startListeningBg();
  }
}

Future<void> startListeningBg() async {
  DatabaseReference ref = FirebaseDatabase.instance
      .ref("CHAT_BOT_ALERT/HOURLY_UPDATES/${constants.apwrimsUUID}");
  SpeechRecognitionResult result;

  await speechToText.listen(
    pauseFor: const Duration(seconds: 3),
    listenFor: const Duration(seconds: 15),
    partialResults: false,
    onResult: (data) async {
      result = data;
      print("wewewewewew-recognizedWords - ${result.recognizedWords}");
      if (result.recognizedWords.isNotEmpty &&
          result.recognizedWords.toLowerCase() == 'yes') {
        print("wewewewewew entered");
        await ref.orderByKey().limitToLast(1).once().then((event) async {
          DataSnapshot snapshot = event.snapshot;
          print("wewewewewew snapshot $snapshot");
          if (snapshot.value != null) {
            dynamic values = snapshot.value;
            values.forEach((key, value) async {
              if (value['isUser'] == false) {
                String responseMessage = value['message'] ?? '';
                print("wewewewewew response message :: $responseMessage");
                await tts.speak(responseMessage);
              }
            });
          }
          await speechToText.stop();
        });
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChatBot Weather',
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreenWidget(),
          '/login': (context) => const LoginScreenWidget(),
          '/home': (context) => const HomeScreenWidget(),
          '/promptManagement': (context) => const PromptManagementView(),
          '/toolInventory': (context) => const ToolInventoryView(),
        },
      ),
    );
  }
}

/// Handling firebase notifications
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  Util.instance.logMessage(
      'on Background: ',
      '${message.notification?.title}/'
          '${message.notification?.body}/${message.notification?.titleLocKey}');
}
