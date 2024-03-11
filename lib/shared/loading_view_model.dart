import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../utils/app_state.dart';



class LoadingViewModel with ChangeNotifier {
  bool _isLoading = false;
  bool _isAlertLoading = false;
  bool _isButtonLoading = false;

  bool get isLoading => _isLoading;
  bool get isAlertLoading => _isAlertLoading;
  bool get isButtonLoading => _isButtonLoading;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  set isAlertLoading(bool isAlertLoading) {
    _isAlertLoading = isAlertLoading;
    notifyListeners();
  }


  set isButtonLoading(bool value) {
    _isButtonLoading = value;
  }

  updateAppStateDeptLocationDetails() {
    AppState.instance.userState = AppState.instance.stateUUIDMapping.keys.first ?? "";
    AppState.instance.stateUUID = AppState.instance.stateUUIDMapping.values.first ?? "";
    AppState.instance.userDistrict = AppState.instance.districtUUIDMapping.keys.first;
    AppState.instance.districtUUID = AppState.instance.districtUUIDMapping.values.first;
    AppState.instance.userBlock = AppState.instance.blockUUIDMapping.keys.first;
    AppState.instance.blockUUID = AppState.instance.blockUUIDMapping.values.first;
    if(AppState.instance.panchayatUUIDMapping.isNotEmpty) {
      AppState.instance.userPanchayat =
          AppState.instance.panchayatUUIDMapping.keys.first;
      AppState.instance.panchayatUUID =
          AppState.instance.panchayatUUIDMapping.values.first ?? "";
    }
    notifyListeners();
  }
}
