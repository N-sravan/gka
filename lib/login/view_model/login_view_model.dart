import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../home/view/home_view.dart';
import '../../services/api_provider.dart';
import '../../utils/app_state.dart';
import '../model/department_user_permission_response.dart';
import '../../shared/loading_view_model.dart';
import '../../utils/network_utils.dart';
import '../../utils/secure_storage_util.dart';
import '../../utils/shared_preference_util.dart';
import '../../utils/util.dart';
import '../model/login_api_response_model.dart' as login;
import '../repository/login_repo.dart';

class LoginViewModel extends LoadingViewModel {
  LoginViewModel({
    required this.repo,
  });

  final LoginRepository repo;
  bool getOtp = false;
  String? mobileNo;
  String? otpEntered;
  final otpKey = GlobalKey();
  final formKey = GlobalKey<FormState>();

  Future<bool> authenticate(
      String userName, String password, BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      late login.LoginResult loginResult;
      String? locUUID;
      String? locName;

      /// Generating token and sending to backend
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      isLoading = true;
      try {
        /// Creating login request parameters
        Map<String, String> params = {
          constants.userName: userName,
        };

        /// Calling the login API
        loginResult = await repo.authenticate(params, context);
        if (loginResult.result  &&
            loginResult.statusCode == 200) {
          login.UserResponse userContent = loginResult.response;
          String encodedContent = json.encode(userContent.toJson());
          if (userContent != null && userContent.userDetailsJson != null) {
            switch (userContent.userDetailsJson.data.locType) {
              case 'state':
                locUUID = userContent
                    .userDetailsJson.data.location!.state![0].stateUUID;
                locName = userContent
                    .userDetailsJson.data.location!.state![0].stateName;
                break;
              default:
                break;
            }
            AppState.instance.userData = encodedContent;
            // AppState.instance.fcmToken = fcmToken!;
            AppState.instance.locType =
            userContent.userDetailsJson.data.locType!;
            AppState.instance.locUUID = locUUID!;
            AppState.instance.locName = locName!;
            AppState.instance.userId = userContent.userId;
            AppState.instance.userName = userContent.username;

            await _setLoginSharedPreferences(
                AppState.instance.userName,
                AppState.instance.userId,
                AppState.instance.locName,
                AppState.instance.locType,
                AppState.instance.userData,
                AppState.instance.locUUID,
                // AppState.instance.fcmToken
            );
            notifyListeners();
          }
          isLoading = false;
          debugPrint("User Details fetched successfully");
          return true;
        }
            } catch (e) {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
      }
    } else {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return false;
  }

  /// Restricting user after 10 unsuccessful attempts
  /// If user reaches 10 attempts then they have to wait for 15 minutes
  Future<bool> restrictLoginAttempts() async {
    int? attempts = await SharedPreferenceUtil.instance
        .getIntPreference(constants.preferenceLoginAttempts);
    double? lastAttemptTime = await SharedPreferenceUtil.instance
        .getDoublePreference(constants.preferenceLastLoginTime);
    double timeDiff =
        (DateTime.now().millisecondsSinceEpoch - lastAttemptTime) / 1000;
    if (timeDiff > constants.lockoutTime) {
      attempts = 0;
      await SharedPreferenceUtil.instance.setPreferenceValue(
          constants.preferenceLoginAttempts,
          attempts,
          constants.preferenceTypeInt);
    }
    attempts = attempts + 1;
    if (attempts >= constants.lockoutAttempts &&
        timeDiff <= constants.lockoutTime) {
      return true;
    }
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceLoginAttempts,
        attempts,
        constants.preferenceTypeInt);
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceLastLoginTime,
        double.parse(DateTime.now().millisecondsSinceEpoch.toString()),
        constants.preferenceTypeDouble);
    return false;
  }

  /// Saving user logged in status, userId,token and refresh token
  /// Initialize userId and username to app state
  _setLoginSharedPreferences(String userName, String userId, String locName,
      String locType, String userData, String locUUID) async {
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceIsLoggedIn, true, constants.preferenceTypeBool);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserName, userName);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserId, userId);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferencelocName, locName);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferencelocUUID, locUUID);
    await SecuredStorageUtil.instance.writeSecureData(constants.preferencelocType, locType);
    // await SecuredStorageUtil.instance.writeSecureData(constants.preferenceFcmToken, fcmToken);
    await SecuredStorageUtil.instance.writeSecureData(
        constants.preferenceLastLoginTime,
        DateTime.now().millisecondsSinceEpoch.toString());
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserData, userData);
  }

  Future<bool?> sendFcmToken(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        int? statusCode = await repo.saveFcmToken(context);

        if (statusCode != null) {
          if (statusCode == 200) {
            isLoading = false;
            notifyListeners();
            return true;
          } else {
            isLoading = false;
            notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong,Please try later'),
            ));
          }
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('FCM TOKEN', 'Error while authenticating $e');
      }
    } else {
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return null;
  }
}