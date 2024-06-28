import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  Future<bool> authenticate(
      String userName, String password, BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      late login.LoginResult loginResult;
      String? locUUID;
      String? locName;

      /// Generating token and sending to backend
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print("fcmToken::$fcmToken");

      isLoading = true;
      try {
        /// Creating login request parameters
        Map<String, String> params = {
          constants.userName: userName,
        };

        /// Calling the login API
        loginResult = await repo.authenticate(params, context);
        if (loginResult.result && loginResult.statusCode == 200) {
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
              case 'district':
                locUUID = userContent.userDetailsJson.data.location!.state![0]
                    .district![0].districtUUID;
                locName = userContent.userDetailsJson.data.location!.state![0]
                    .district![0].districtName;
                break;
              case 'mandal':
                locUUID = userContent.userDetailsJson.data.location!.state![0]
                    .district![0].mandal![0].mndalUUID;
                locName = userContent.userDetailsJson.data.location!.state![0]
                    .district![0].mandal![0].mandalName;
                break;
              default:
                break;
            }
            String locType = userContent.userDetailsJson.data.locType;
            String userId = userContent.userId;
            String userName = userContent.username;
            String role = '';
            setAppStateValues(
                encodedContent, locUUID, locName, locType, userId, userName,role);

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

  Future<bool> authenticateForKerala(
      String userName, String password, BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      // if (!await restrictLoginAttempts()) {
      late KeralaLoginResult loginResult;
      isLoading = true;
      try {
        /// Creating login request parameters
        Map<String, String> params = {
          constants.userName: userName,
          constants.password: password,
          constants.clientId: constants.agriwiseClient,
          constants.grantType: constants.password,
          'scope': 'openid'
        };

        /// Calling the login API
        loginResult = await repo.authenticationForKerala(params, context);

        if (loginResult.statusCode == 200 && loginResult.accessToken != null) {
          /// Login is successful
          Map<String, dynamic> decodedToken =
              JwtDecoder.decode(loginResult.accessToken!);
          String userId = decodedToken["sub"];
          await _setLoginSharedPreferencesForKerala(userName, userId,
              loginResult.accessToken!, loginResult.refreshToken!);
          Map csrfResponse = await repo.fetchCsrfToken(context);
          if (csrfResponse["statusCode"] == 200) {
            await _setCSRFSharedPreferences(
                csrfResponse["response"]["tokens"]["csrf"]);
            DepartmentUserPermissionsResponse userPermissionsResponse;
            userPermissionsResponse = await ApiProvider.instance
                .fetchUserPermissionsForDepartmentLogin(context);
            if (userPermissionsResponse.statusCode == 200) {
              dept.Meta? userContent = userPermissionsResponse.response?.meta;
              String encodedContent = json.encode(userContent?.toJson());
              if (userContent != null) {
                if (userContent.userDetails != null &&
                    userContent.userDetails!.data!.location != null) {
                  String locUUID = '';
                  String locName = '';
                  String? locType = userContent.userDetails!.data!.locType;
                  switch (userContent.userDetails!.data!.locType) {
                    case 'country':
                      locUUID = userContent.userDetails!.data!.location!
                          .country![0].countryUUID!;
                      locName = userContent.userDetails!.data!.location!
                          .country![0].countryName!;
                      break;
                    case 'state':
                      locUUID = userContent.userDetails!.data!.location!
                          .country![0].state![0].stateUUID!;
                      locName = userContent.userDetails!.data!.location!
                          .country![0].state![0].stateName!;
                      break;
                    case 'district':
                      locUUID = userContent.userDetails!.data!.location!
                          .country![0].state![0].district![0].districtUUID!;
                      locName = userContent.userDetails!.data!.location!
                          .country![0].state![0].district![0].districtName!;
                      break;
                    case 'mandal':
                      locUUID = userContent
                          .userDetails!
                          .data!
                          .location!
                          .country![0]
                          .state![0]
                          .district![0]
                          .block![0]
                          .blockUUID!;
                      locName = userContent
                          .userDetails!
                          .data!
                          .location!
                          .country![0]
                          .state![0]
                          .district![0]
                          .block![0]
                          .blockName!;
                      break;
                    default:
                      break;
                  }
                  setAppStateValues(encodedContent, locUUID, locName, locType,
                      userId, userName,"officer");
                }
              }
              isLoading = false;
              notifyListeners();
              return true;
            } else {
              isLoading = false;
              notifyListeners();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(constants.genericErrorMsg),
              ));
            }
          } else {
            isLoading = false;
            notifyListeners();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

  Future<bool?> authenticateForAp(
      String userName, String password, BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      late apLogin.ApLoginResult loginResult;
      String? locUUID;
      String? locName;

      /// Generating token and sending to backend
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      print("fcmToken::$fcmToken");

      isLoading = true;
      try {
        /// Creating login request parameters
        Map<String, String> params = {
          constants.userName: userName,
        };

        /// Calling the login API
        loginResult = await repo.authenticationForAp(params, context);
        if (loginResult.result != null) {
          if (loginResult.result?.status != null &&
              loginResult.result?.status == 200) {
            apLogin.Content? userContent = loginResult.result!.content;
            String encodedContent = json.encode(userContent?.toJson());
            String? userId = userContent?.username;
/*            login.Content? userContent = login.Content(
              username: "APWRIMS",
              userId: '44',
              userDetailsJson: login.UserDetailsJson(
                data: login.Data(
                  locType: 'mandal',
                  location: login.Location(state: [
                    login.State(
                        stateName: 'Andhra Pradesh',
                        stateUUID: "6f86292b-dd9a-4987-bb8f-c3940263b349",
                        district: [
                          login.District(
                              districtName: 'Srikakulam',
                              districtUUID:
                              '00bb53a0-a27e-46c4-9016-fe9545766cb9',
                              mandal: [
                                login.Mandal(
                                    mandalName: 'BURJA',
                                    mndalUUID:
                                    '1437f9bf-207a-4d7e-bd9d-0af79b6ef8db')
                              ]),
                        ]),
                  ]),
                ),
              ),
            );*/

            if (userContent != null &&
                userContent.userDetailsJson != null &&
                userContent.userDetailsJson!.data != null) {
              String? locType = userContent.userDetailsJson!.data!.locType;
              switch (userContent.userDetailsJson!.data!.locType) {
                case 'mandal':
                  locUUID = userContent.userDetailsJson!.data!.location!
                      .state![0].district![0].mandal![0].mndalUUID;
                  locName = userContent.userDetailsJson!.data!.location!
                      .state![0].district![0].mandal![0].mandalName;
                  break;
                case 'district':
                  locUUID = userContent.userDetailsJson!.data!.location!
                      .state![0].district![0].districtUUID;
                  locName = userContent.userDetailsJson!.data!.location!
                      .state![0].district![0].districtName;
                  break;
                case 'state':
                  locUUID = userContent
                      .userDetailsJson!.data!.location!.state![0].stateUUID;
                  locName = userContent
                      .userDetailsJson!.data!.location!.state![0].stateName;
                  break;
                default:
                  break;
              }
              setAppStateValues(
                  encodedContent, locUUID, locName, locType, userId, userName,"");
              notifyListeners();
            }
            isLoading = false;
            debugPrint("User Details fetched successfully");
            return true;
          }
        } else {
          /// Login is unsuccessful
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
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
      String locType, String userData, String locUUID, String role) async {
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
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferencelocType, locType);
    // await SecuredStorageUtil.instance.writeSecureData(constants.preferenceFcmToken, fcmToken);
    await SecuredStorageUtil.instance.writeSecureData(
        constants.preferenceLastLoginTime,
        DateTime.now().millisecondsSinceEpoch.toString());
    await SecuredStorageUtil.instance.writeSecureData(constants.preferenceUserData, userData);
    await SecuredStorageUtil.instance.writeSecureData(constants.preferenceUserRole, role);
  }

  _setLoginSharedPreferencesForKerala(
      String userName, String userId, String token, String refreshToken) async {
    await SharedPreferenceUtil.instance.setPreferenceValue(
        constants.preferenceIsLoggedIn, true, constants.preferenceTypeBool);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserName, userName);
    await SecuredStorageUtil.instance
        .writeSecureData(constants.preferenceUserId, userId);
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

  Future<void> setAppStateValues(
    String encodedContent,
    String? locUUID,
    String? locName,
    String? locType,
    String? userId,
    String? userName, String role,
  ) async {
    AppState.instance.userData = encodedContent;
    // AppState.instance.fcmToken = fcmToken!;
    AppState.instance.locType = locType!;
    AppState.instance.locUUID = locUUID!;
    AppState.instance.locName = locName!;
    AppState.instance.userId = userId!;
    AppState.instance.userName = userName!;
    AppState.instance.role = role;

    await _setLoginSharedPreferences(
      AppState.instance.userName,
      AppState.instance.userId,
      AppState.instance.locName,
      AppState.instance.locType,
      AppState.instance.userData,
      AppState.instance.locUUID,
      AppState.instance.role,
      // AppState.instance.fcmToken
    );
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
}
