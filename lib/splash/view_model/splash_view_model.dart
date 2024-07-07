import 'dart:async';
import 'dart:convert';
import 'package:gka/login/view/login_view.dart';
import 'package:gka/permissions/view/permissions_view.dart';
import 'package:gka/utils/navigation_util.dart';

import '../../chat_window.dart';
import '../../home/view/home_view.dart';
import '../../login/model/department_user_permission_response.dart';
import '../../login/model/login_api_response_model.dart';
import '../../login/model/user_permission_response_model.dart';
import '../../main.dart';
import '../../services/api_provider.dart';
import 'package:flutter/material.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import '../../../utils/shared_preference_util.dart';
import '../../shared/loading_view_model.dart';
import '../../utils/secure_storage_util.dart';
import '../../utils/util.dart';

class SplashViewModel extends LoadingViewModel {
  checkPermissionsAndNavigate(BuildContext context) async {
    await _checkIfUserIsLoggedIn(context);
  }

  /// Navigator function based on route argument
  _startSplashTimerAndNavigate(BuildContext context, String routeName) {
    Timer(const Duration(seconds: constants.splashDuration), () async {
      if (routeName == '/login') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreenWidget()),
        );
      }
    });
  }

  /// Checking if the user is logged in, from secure storage, and
  /// navigating accordingly
  _checkIfUserIsLoggedIn(BuildContext context) async {
    bool isLoggedIn = await SharedPreferenceUtil.instance
        .getBoolPreference(constants.preferenceIsLoggedIn);
    dynamic userName = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUserName);
    dynamic userId = await SecuredStorageUtil.instance.readSecureData(constants.preferenceUserId);
    dynamic sessionId = await SecuredStorageUtil.instance.readSecureData(constants.preferenceSessionId);
    dynamic token = await SecuredStorageUtil.instance.readSecureData(constants.preferenceToken);


    if (userId != null && userId.isNotEmpty && isLoggedIn) {
      AppState.instance.userId = userId!;
      AppState.instance.userName = userName;
      AppState.instance.token = token;
      AppState.instance.sessionId = sessionId;
      if (constants.projectId == constants.keralaUUID) {
        NavigationUtil.instance.navigateToRoleScreen(context);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatWindow(
              isFromHistory: false,
              sessionId: sessionId,
            ),
          ),
        );
      }
    } else {
      // User isn't logged in
      if (constants.projectId == constants.keralaUUID) {
        NavigationUtil.instance.navigateToRoleScreen(context);
      } else {
        _startSplashTimerAndNavigate(context, '/login');
      }
    }
  }
}
