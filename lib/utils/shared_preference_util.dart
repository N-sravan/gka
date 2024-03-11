import 'package:shared_preferences/shared_preferences.dart';

import 'common_constants.dart' as constants;

class SharedPreferenceUtil {
  static SharedPreferenceUtil? _instance;

  SharedPreferenceUtil._();

  static SharedPreferenceUtil get instance =>
      _instance ??= SharedPreferenceUtil._();

  Future<bool> getBoolPreference(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key) ?? false;
  }

  Future<int> getIntPreference(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key) ?? 0;
  }

  Future<double> getDoublePreference(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getDouble(key) ?? 0.0;
  }

  Future<String?> getStringPreference(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key) != null &&
        preferences.getString(key)!.isNotEmpty
        ? preferences.getString(key)
        : '';
  }

  setPreferenceValue(String key, var value, String dataType) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    Future<bool>? status;

    switch (dataType) {
      case constants.preferenceTypeInt:
        status = preferences.setInt(key, value);
        break;
      case constants.preferenceTypeBool:
        status = preferences.setBool(key, value);
        break;
      case constants.preferenceTypeDouble:
        status = preferences.setDouble(key, value);
        break;
      case constants.preferenceTypeString:
        status = preferences.setString(key, value);
        break;
      case constants.preferenceTypeStringList:
        status = preferences.setStringList(key, value);
        break;
    }

    return status;
  }
}
