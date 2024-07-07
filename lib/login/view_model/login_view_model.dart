import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gka/login/model/session_details_response_model.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../services/api_provider.dart';
import '../../utils/app_state.dart';
import '../../utils/navigation_util.dart';
import '../model/ap_login_response_model.dart' as apLogin;
import '../../shared/loading_view_model.dart';
import '../../utils/network_utils.dart';
import '../../utils/secure_storage_util.dart';
import '../../utils/shared_preference_util.dart';
import '../../utils/util.dart';
import '../model/department_user_permission_response.dart' as dept;
import '../model/department_user_permission_response.dart';
import '../model/kerala_login_response_model.dart';
import '../model/login_api_response_model.dart' as login;
import '../model/login_api_response_model.dart';
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
  String selectedRole = constants.farmer;

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

  _setLoginSharedPreferences(
      String userName, String userId, String token, String sessionId) async {
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceIsLoggedIn, true, constants.preferenceTypeBool);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserName, userName);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserId, userId);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceSessionId, sessionId);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceToken, token);
    await SecuredStorageUtil.instance.writeSecureData(
        constants.preferenceLastLoginTime,
        DateTime.now().millisecondsSinceEpoch.toString());
    AppState.instance.sessionId = sessionId;
    AppState.instance.userName = userName;
    AppState.instance.userId = userId;
    AppState.instance.token = token;
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
        Util.instance.logMessage('FCM TOKEN', 'Error while authenticating $e');
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

/*  _setLoginSharedPreferences(
      String userName, String userId, String token, String refreshToken) async {
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceIsLoggedIn, true, constants.preferenceTypeBool);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserName, userName);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserId, userId);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceToken, token);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceToken, token);
    await SecuredStorageUtil.instance.writeSecureData(
        constants.preferenceLastLoginTime,
        DateTime.now().millisecondsSinceEpoch.toString());
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceRefreshToken, refreshToken);
    AppState.instance.refreshToken = refreshToken;
    AppState.instance.userName = userName;
    AppState.instance.userId = userId;
    AppState.instance.token = token;
  }*/

  _setCSRFSharedPreferences(String csrfToken) async {
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceCsrfToken, csrfToken);
    AppState.instance.csrfToken = csrfToken;
  }

  _setUserPermissionsSharedPreferences(
      String email, String mobileNo, String firstName, String roleName) async {
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserEmail, email);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserMobileNo, mobileNo);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserFirstName, firstName);
    AppState.instance.userEmail = email;
    AppState.instance.userMobileNo = mobileNo;
    AppState.instance.userName = firstName;
    AppState.instance.userAssignedRole = roleName;
  }

  roleSelection(String role, BuildContext context) {
    selectedRole = role;
    notifyListeners();
  }

  navigationBasedOnRole(BuildContext context) {
    if (selectedRole == constants.farmer) {
      AppState.instance.role = constants.farmer;
      NavigationUtil.instance
          .navigateToFarmerLoginScreen(context, selectedRole);
    } else if (selectedRole == constants.department) {
      AppState.instance.role = constants.department;
      NavigationUtil.instance
          .navigateToDepartmentLoginScreen(context, selectedRole);
    }
  }

  generateOTP() {
    getOtp = !getOtp;
    notifyListeners();
  }

  void updateGetOtp(bool value) {
    getOtp = value;
    notifyListeners();
  }

  void clearAllData() {
    getOtp = false;
    notifyListeners();
  }

  bool validateOTP(BuildContext context) {
    if (otpEntered == '1234') {
      AppState.instance.userMobileNo = mobileNo!;
      AppState.instance.stateUUID = constants.keralaUUID;
      notifyListeners();
      return true;
    } else {
      Fluttertoast.showToast(
          msg: constants.otpErrorMsg, toastLength: Toast.LENGTH_LONG);
      return false;
    }
  }

  void updatedOTPValue(String value) {
    otpEntered = value;
    notifyListeners();
  }

  bool validateMobileNo(String? mobileNo) {
    // Regular expression pattern for a valid mobile number
    final RegExp regex = RegExp(r'^[6-9]\d{9}$');

    // Check if the value matches the regex pattern
    if (regex.hasMatch(mobileNo!)) {
      return true; // Valid mobile number
    }
    return false; // Invalid mobile number
  }

  Future<bool> authenticateForFieldRishi(
      String userName, String password, BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      // if (!await restrictLoginAttempts()) {
      late SessionDetails? sessionDetails;
      isLoading = true;
      try {
        Map<String, String> params = {
          constants.userName: userName,
          constants.password: password,
        };

        sessionDetails =
            await repo.authenticationForFieldRishi(params, context);

        if (sessionDetails != null &&
            sessionDetails.token!.isNotEmpty &&
            sessionDetails.sessionId!.isNotEmpty) {
          await _setLoginSharedPreferences(userName, sessionDetails.userId,
              sessionDetails.token!, sessionDetails.sessionId!);
          isLoading = false;
          print("wewewew sessionId::${sessionDetails.sessionId}");
          return true;
        } else {
          /// Login is unsuccessful
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.genericErrorMsg),
          ));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
    return false;
  }
}
