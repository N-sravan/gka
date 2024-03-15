import 'package:flutter/material.dart';
import 'package:gka/home/view/home_view.dart';
import 'package:gka/login/view/login_view.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/app_state.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../../utils/shared_preference_util.dart';
import '../../login/model/department_user_permission_response.dart' as response;
import '../../shared/loading_view_model.dart';
import '../../utils/secure_storage_util.dart';

class PermissionsViewModel extends LoadingViewModel {
  requestPermissionsAndNavigate(BuildContext context) async {
    isLoading = true;
    /// Checking if the user has given runtime permissions
    bool arePermissionsGiven = await _checkPermissions();
    if (arePermissionsGiven) {
      /// Check if user is logged in, and navigate
      _checkIfUserIsLoggedIn(context);
    } else {
      /// Permissions not granted, show permissions dialog
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.location,
        Permission.microphone
      ].request();
      if (statuses.isNotEmpty) {
        PermissionStatus? locationPermission = statuses[Permission.location];
        PermissionStatus? cameraPermission = statuses[Permission.camera];
        PermissionStatus? microphonePermission = statuses[Permission.microphone];
        if (locationPermission == PermissionStatus.granted &&
            cameraPermission == PermissionStatus.granted &&
            microphonePermission == PermissionStatus.granted) {
          /// All permissions are granted
          await _checkIfUserIsLoggedIn(context);
        } else if (locationPermission == PermissionStatus.denied ||
            cameraPermission == PermissionStatus.denied || microphonePermission == PermissionStatus.denied) {
          /// One or all permissions are denied
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.permissionsErrorMsg),
          ));
        } else if (locationPermission == PermissionStatus.permanentlyDenied ||
            cameraPermission == PermissionStatus.permanentlyDenied || microphonePermission == PermissionStatus.permanentlyDenied) {
          /// One or all permissions are permanently denied, opening settings
          await _checkIfUserIsLoggedIn(context);
          //openAppSettings();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(constants.permissionsErrorMsg),
          ));
        }
        isLoading = false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.permissionsErrorMsg),
        ));
        isLoading = false;
      }
    }
  }

  _checkPermissions() async {
    /// Check if all permissions have been given
    var cameraStatus = await Permission.camera.status;
    var locationStatus = await Permission.location.status;
    var storageStatus = await Permission.storage.status;
    if (locationStatus.isDenied ||
        cameraStatus.isDenied ||
        locationStatus.isPermanentlyDenied ||
        cameraStatus.isPermanentlyDenied ||
        storageStatus.isDenied ||
        storageStatus.isPermanentlyDenied) {
      /// Permissions are needed
      return false;
    } else {
      /// Permissions have been given
      return true;
    }
  }

  /// Checking if the user is logged in, from secure storage, and
  /// navigate accordingly
  _checkIfUserIsLoggedIn(BuildContext context) async {
    bool isLoggedIn = await SharedPreferenceUtil.instance
        .getBoolPreference(constants.preferenceIsLoggedIn);
    dynamic userId = await SecuredStorageUtil.instance
        .readSecureData(constants.preferenceUserName);
    if (userId != null && userId.isNotEmpty && isLoggedIn) {
      AppState.instance.userName = userId;
      // Define classes for Location, Country, State, District, Block, and Panchayat if not already defined

      response.Meta data = response.Meta(
        userId: "b7a7ca67-6fd3-4f2e-97c6-b9b84fdbd7da",
        username: "kerala_ao",
        firstName: "Aswin",
        lastName: "Kumar",
        email: "keralaao@gmail.com",
        mobileNo: "+919889786767",
        userDetails: response.UserDetails(
          data: response.Data(
              locType: "Panchayat",
              location: response.Location(
                  country: [
                    response.Country(
                        countryName: "INDIA",
                        countryUUID: "d6b37905-d2d3-4275-9317-d9b6f47cd783",
                        state: [
                          response.State(
                              stateName: "KERALA",
                              stateUUID: "62d3dc99-5bc3-4303-8be1-d4fa1f7deee5",
                              district: [
                                response.District(
                                    districtName: "Palakkad",
                                    districtUUID: "1270f554-20cc-43ee-803e-1532f00e047c",
                                    block: [
                                      response.Block(
                                          blockName: "Sreekrishnapuram",
                                          blockUUID: "db64691f-a7de-4e88-b5af-ecbe4dc6d191",
                                          panchayat: [
                                            response.Panchayat(
                                                panchayatName: "Karimpuzha",
                                                panchayatUUID: "0ec4c732-5db9-4a3e-896a-f7baf24b2966"
                                            )
                                          ]
                                      )
                                    ]
                                )
                              ]
                          )
                        ]
                    )
                  ]
              )
          ),
          scope: null,
        ),
        createdTs: null,
        updatedTs: null,
        lastLoginTs: "2024-03-11T10:45:55.398+00:00",
        status: true,
        title: null,
        customerId: "931e0a8e-54e9-49f4-87db-d6e1fe350432",
        customerName: "keralacustomer",
        customAttributes: null,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreenWidget(data: data)),
      );
    } else {
      /// User isn't logged in
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreenWidget()),
      );
    }
  }
}
