import 'dart:async';
import 'package:gka/chat/view/chat_view.dart';
import 'package:gka/login/view/login_view.dart';
import '../../chat/view/chat_view_recording.dart';
import '../../chat_window.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import '../../../utils/shared_preference_util.dart';
import '../../shared/loading_view_model.dart';
import '../../utils/network_utils.dart';
import '../../utils/secure_storage_util.dart';
import '../../utils/util.dart';

class SplashViewModel extends LoadingViewModel {

  checkPermissionsAndNavigate(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreenWidget()),
    );
  }

  /// Navigator function based on route argument
  _startSplashTimerAndNavigate(BuildContext context, String routeName) {
    Timer(const Duration(seconds: constants.splashDuration), () async {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenWidget()),
      );
    });
  }

  /// Checking if the user is logged in, from secure storage, and
  /// navigating accordingly
  _checkIfUserIsLoggedIn(BuildContext context) async {
    bool isLoggedIn = await SharedPreferenceUtil.instance
        .getBoolPreference(constants.preferenceIsLoggedIn);
    dynamic userName = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUserName);
    dynamic userId = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUserId);
    dynamic sessionId = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceSessionId);
    dynamic token = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceToken);
    dynamic refreshToken = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceRefreshToken);

    if (userId != null && userId.isNotEmpty && isLoggedIn) {
      AppState.instance.userId = userId!;
      AppState.instance.userName = userName;
      AppState.instance.token = token;
      AppState.instance.sessionId = sessionId;
      AppState.instance.language = 'english';
      AppState.instance.isEnglish = true;
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatView(
                  sessionId: AppState.instance.sessionId,isFromHistory: false,
                )),
      );
    } else {
      // User isn't logged in
      _startSplashTimerAndNavigate(context, '/login');
    }
  }
}
