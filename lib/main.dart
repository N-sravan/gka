import 'dart:async';
import 'package:gka/chat/repo/chat_repo.dart';
import 'package:gka/chat/repo/prompt_management_repo.dart';
import 'package:gka/chat/view_model/prompt_management_view_model.dart';
import 'package:gka/home/repo/home_repo.dart';
import 'package:gka/home/view_model/home_view_model.dart';
import 'package:gka/settings_view.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gka/chat/view_model/chat_view_model.dart';
import 'package:gka/login/repository/login_repo.dart';
import 'package:gka/login/view/login_view.dart';
import 'package:gka/login/view_model/login_view_model.dart';
import 'package:gka/splash/view/splash_view.dart';
import 'package:gka/splash/view_model/splash_view_model.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home/view/home_view.dart';
import 'locator.dart';

PermissionStatus? notificationStatus;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();

  setupLocator();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

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
          create: (_) => HomeViewModel(repo: locator<HomeRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => PromptManagementViewModel(
              repository: locator<PromptManagementRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
  // await initializeService();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ChatBot Weather',
        // home: const MyHomePage(title: 'ChatBot Weather'),
        initialRoute: constants.initialRoute,
        routes: {
          constants.initialRoute: (context) => const SplashScreenWidget(),
          constants.roleRoute: (context) => const LoginScreenWidget(),
          constants.homeRoute: (context) => const HomeScreenWidget(),
          constants.settingsRoute: (context) => const SettingsPage(),
        },
        onGenerateRoute: (settings) {
          final String? data = settings.arguments as String?;
          if (settings.name == constants.loginRoute) {
            return MaterialPageRoute(
              builder: (context) => LoginScreenWidget(role: data ?? ''),
            );
          } else if (settings.name == constants.departmentLoginRoute) {
            return MaterialPageRoute(
              builder: (context) => LoginScreenWidget(role: data ?? ''),
            );
          }
          return null;
        },
      ),
    );
  }
}
