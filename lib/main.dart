import 'dart:convert';
import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gka/MyApp.dart';
import 'package:gka/chat_bubble.dart';
import 'package:gka/chat_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyBMFHOuaBOHBt73rM8IvfVpWrnQ1fM7y1o',
        appId: '1:298120067435:ios:54153991ecce35f2bf342e',
        messagingSenderId: '298120067435',
        projectId: 'gpt-drive-thru',
        storageBucket: 'gpt-drive-thru.appspot.com',
        iosBundleId: 'com.vassar.gka',
      )
    //options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const ScreenUtilInit(
      child: MaterialApp(
        title: 'GPT Drive-Thru',
        home: MyHomePage(title: 'GPT Drive-Thru'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const ui.Size.fromHeight(20),
        child: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(widget.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset('assets/images/drive_thru_menu.png'),
          const ChatWidget(),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({
    super.key,
  });

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  bool isFirstTime = true;
  String? sessionId;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: isFirstTime ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 200,
                height: 200,
                child: Image.asset('assets/images/gka_logo.png')),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text("Please place your order!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black),),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("Your Voice, Your Order, Your Way!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),),
            ),
            SizedBox(
              width: 104,
              height: 104,
              child: GestureDetector(
                onTap: () async {
                  String? newSessionId = await createSession();
                  if (newSessionId != null) {
                    setState(() {
                      isFirstTime = false;
                      sessionId = newSessionId;
                    });
                  }
                },
                child: Padding(padding: const EdgeInsets.only(top: 16.0),
                    child: Image.asset('assets/images/mic.png')),
              ),
            )
          ],
        ) : ChatWindow(isFirstTime:  isFirstTime, finishSession: (bool finishSession) {
          if (finishSession) {
            setState(() {
              isFirstTime = true;
            });
          }
        }, sessionId: sessionId!,)
    );
  }

  Future<String?> createSession() async {
    try {
      String url = "https://dashing-next-rat.ngrok-free.app/vassar_kfc_chatbot/create_session";
      //String url = 'https://vani.vassardigital.ai/vassar_kfc_chatbot/create_session';

      Response response = await post(
          Uri.parse(url),
          body: jsonEncode({
            "user_id" : "16ed2ead-9931-4178-b178-d484e9ceb181"
          }));

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["session_id"];
      }
    } catch (error, stacktrace) {
      print("Error Stacktrace $error $stacktrace");
    }
    return null;
  }
}
