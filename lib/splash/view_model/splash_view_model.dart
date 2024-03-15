import 'dart:async';
import 'package:gka/login/view/login_view.dart';
import 'package:gka/permissions/view/permissions_view.dart';

import '../../login/model/department_user_permission_response.dart';
import '../../login/model/user_permission_response_model.dart';
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
    /// Check if all permissions have been given
    var locationStatus = await permission_handler.Permission.location.status;
    var cameraStatus = await permission_handler.Permission.camera.status;
    var microphoneStatus = await permission_handler.Permission.microphone.status;

    /// If any permission is denied, navigate to permissions screen
    if (cameraStatus.isDenied ||
        cameraStatus.isPermanentlyDenied ||
        locationStatus.isDenied ||
        locationStatus.isPermanentlyDenied ||
        microphoneStatus.isPermanentlyDenied ||
        microphoneStatus.isPermanentlyDenied ) {
      /// Permissions are needed
      _startSplashTimerAndNavigate(context, '/login');
    } else {
      /// Permissions have been given, check if user is logged in
      await _checkIfUserIsLoggedIn(context);
      // Util.instance.checkCurrentLocale(context);
    }
  }

  /// Navigator function based on route argument
  _startSplashTimerAndNavigate(BuildContext context, String routeName) {
    Timer(const Duration(seconds: constants.splashDuration), () async {
      if (routeName == '/login') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreenWidget()),
        );
      }  else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PermissionsScreenWidget()),
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
    dynamic userFirstName = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUserFirstName);
    dynamic userId = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUserId);
    dynamic token = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceToken);
    dynamic refreshToken = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceRefreshToken);
    dynamic csrfToken = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceCsrfToken);
    dynamic userSelectedRoleScreen = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUserRole);
    if (userId != null && userId.isNotEmpty && isLoggedIn && userSelectedRoleScreen != null) {
      AppState.instance.userName = userFirstName;
      AppState.instance.token = token;
      AppState.instance.refreshToken = refreshToken;
      AppState.instance.userId = userId;
      AppState.instance.csrfToken = csrfToken;
      AppState.instance.role = userSelectedRoleScreen;
    if(userSelectedRoleScreen == constants.department) {
        DepartmentUserPermissionsResponse userPermissionsResponse = await ApiProvider
            .instance.fetchUserPermissionsForDepartmentLogin(context);
        if(userPermissionsResponse.statusCode == 200){
          try {
            await Util.instance.fetchUserAssignedLocationHierarchyDept(
                userPermissionsResponse);
            updateAppStateDeptLocationDetails();
            await _setUserPermissionsSharedPreferences(
                userPermissionsResponse.response!.meta!.email!,
                userPermissionsResponse.response!.meta!.mobileNo!,
                userPermissionsResponse.response!.permissions!.kRISHIDSS!.roleName!);
            // _startSplashTimerAndNavigate(context, constants.deptOptionSelectionRoute);
          }catch(e){
            // NavigationUtil.instance.navigateToRoleScreen(context);
          }
        } else {
          // NavigationUtil.instance.navigateToRoleScreen(context);
        }
      }
    } else {
      /// User isn't logged in
      // NavigationUtil.instance.navigateToRoleScreen(context);
    }
  }

  _setUserPermissionsSharedPreferences(String email, String mobileNo,String roleName) async {
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserEmail, email);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserMobileNo, mobileNo);
    AppState.instance.userEmail = email;
    AppState.instance.userMobileNo = mobileNo;
    AppState.instance.userAssignedRole = roleName;
  }

}
