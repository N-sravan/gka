import 'dart:async';
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

  Future<void> authenticate(
      String userName, String password, BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      // if (!await restrictLoginAttempts()) {
      late LoginResult loginResult;
      isLoading = true;
      try {
        /// Creating login request parameters
        Map<String, String> params = {
          constants.userName: userName,
          constants.password: password,
          constants.clientId: constants.agriwiseClient,
          constants.grantType: constants.password,
        };

        /// Calling the login API
        loginResult = await repo.authenticate(params, context);

        if (loginResult.statusCode == 200 && loginResult.accessToken != null) {
          /// Login is successful
          // String? fcmToken = await FirebaseMessaging.instance.getToken();
          // print("token::${fcmToken}");
          Map<String, dynamic> decodedToken =
              JwtDecoder.decode(loginResult.accessToken!);
          String userId = decodedToken["sub"];
          await _setLoginSharedPreferences(userName, userId,
              loginResult.accessToken!, loginResult.refreshToken!);
          Map csrfResponse = await repo.fetchCsrfToken(context);
          if (csrfResponse["statusCode"] == 200) {
            await _setCSRFSharedPreferences(
                csrfResponse["response"]["tokens"]["csrf"]);
            DepartmentUserPermissionsResponse userPermissionsResponse;
            userPermissionsResponse = await ApiProvider.instance
                .fetchUserPermissionsForDepartmentLogin(context);
            if (userPermissionsResponse.statusCode == 200) {
              await _setUserPermissionsSharedPreferences(
                  userPermissionsResponse.response!.meta!.email!,
                  userPermissionsResponse.response!.meta!.mobileNo!,
                  userPermissionsResponse.response!.meta!.firstName!);
              await Util.instance.fetchUserAssignedLocationHierarchyDept(
                  userPermissionsResponse);
              updateAppStateDeptLocationDetails();
              isLoading = false;
              notifyListeners();
              Meta? userData = userPermissionsResponse.response?.meta;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>HomeScreenWidget(data: userData!,)));
            } else {
              isLoading = false;
              notifyListeners();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(constants.genericErrorMsg),
              ));
            }
          } else {
            isLoading = false;
            notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(constants.genericErrorMsg),
            ));
          }
        } else {
          /// Login is unsuccessful
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(loginResult.errorDescription!),
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
      /*} else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.toManyLoginAttempts),
        ));
      }*/
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(constants.noNetworkAvailability),
      ));
    }
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
  _setLoginSharedPreferences(
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
  }

  _setCSRFSharedPreferences(String csrfToken) async {
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceCsrfToken, csrfToken);
 /*   await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserRole, AppState.instance.role);*/
    AppState.instance.csrfToken = csrfToken;
  }

  _setUserPermissionsSharedPreferences(
      String email, String mobileNo, String firstName) async {
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserEmail, email);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserMobileNo, mobileNo);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserFirstName, firstName);
    AppState.instance.userEmail = email;
    AppState.instance.userMobileNo = mobileNo;
    AppState.instance.userName = firstName;
  }

  void updateGetOtp(bool value) {
    getOtp = value;
    notifyListeners();
  }

  void clearAllData() {
    getOtp = false;
    notifyListeners();
  }

  Future<void> updateIsFarmSurvey(bool value) async {
    await SecuredStorageUtil.instance.writeSecureData(
        constants.preferenceUserSelectedFarm, value.toString());
    AppState.instance.isFarmSurvey = value;
    notifyListeners();
  }

  void formatMobileNo(String? mobileNum) {
    mobileNo = mobileNum!.replaceFirst("+91", "");
    notifyListeners();
  }

  void updatedOTPValue(String value) {
    otpEntered = value;
    notifyListeners();
  }

  bool validateOTP(BuildContext context) {
    if (otpEntered == '1234') {
      AppState.instance.userMobileNo = mobileNo!;
      AppState.instance.stateUUID = constants.keralaStateUUID;
      notifyListeners();
      return true;
    } else {
      Fluttertoast.showToast(
          msg: constants.otpErrorMsg, toastLength: Toast.LENGTH_LONG);
      return false;
    }
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
}
