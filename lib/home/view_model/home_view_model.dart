import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gka/chat/view/chat_view.dart';
import 'package:gka/home/model/available_prompt_response_model.dart';
import 'package:gka/home/repository/home_repo.dart';
import 'package:gka/login/model/login_api_response_model.dart';
import 'package:gka/shared/loading_view_model.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import 'package:fluttertoast/fluttertoast.dart';
import '../../login/view/login_view.dart';
import '../../utils/app_state.dart';
import '../../utils/network_utils.dart';
import '../../utils/secure_storage_util.dart';
import '../../utils/util.dart';
import '../model/available_models.dart' as model;

class HomeViewModel extends LoadingViewModel {
  HomeViewModel({
    required this.repo,
  });

  final HomeRepository repo;

  String selectedValue = '';
  String selectedLang = '';
  String selectedModel = '';
  List<String> selectionList = ['Internal LLM', 'External LLM'];
  List<String> langList = ['English', 'Telugu'];
  List<String>? modelList = [];
  List<Response>? modelResponseList = [];
  Map<String,String> modelNameUuidMapping = {};
  Map<String,String> promptTemplateIntentMapping = {};

  /*final StreamController<ReceivedNotification>
      didReceiveLocalNotificationStream =
      StreamController<ReceivedNotification>.broadcast();*/

  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  void updateSelectedModel(String value) {
    selectedModel = value;
    AppState.instance.modelName = value;
    AppState.instance.modelUUID = modelNameUuidMapping[value]!;
    notifyListeners();
  }

  void updateSelectedValue(String value) {
    selectedValue = value;
    notifyListeners();
  }

  void updateSelectedLanguage(String value) {
    selectedLang = value;
    notifyListeners();
  }

  setLogoutSharedPreferences(BuildContext context) async {
    await SecuredStorageUtil.instance.deleteAllSecureData();
    AppState.instance.userName = '';
    AppState.instance.userData = '';
    AppState.instance.userId = '';
    AppState.instance.locType = '';
    AppState.instance.locUUID = '';
    AppState.instance.locName = '';
    AppState.instance.fcmToken = '';
    AppState.instance.isTeluguSelected = false;
    notifyListeners();
  }

  Future<bool?> deleteToken(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        int? statusCode = await repo.deleteToken(context);

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
            .logMessage('Login Model', 'Error while authenticating $e');
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

  Future? getAvailableModels(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        model.AvailabeModelResponse availabeModelResponse = await repo.fetchModels(context);

        if (availabeModelResponse.statusCode == 200 && availabeModelResponse.result == true) {
          if(availabeModelResponse.response !=null && availabeModelResponse.response?.length !=0) {
            for(int i=0;i<availabeModelResponse.response!.length;i++){
              modelNameUuidMapping.addAll({availabeModelResponse.response![i].modelName! : availabeModelResponse.response![i].modelUuid!});
              modelList!.add(availabeModelResponse.response![i].modelName!);
            }
            isLoading = false;
            print("weweweww modelNameUuidMapping ${modelNameUuidMapping}");
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
          ));
        }
            } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
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

  Future? getAvailablePrompts(BuildContext context) async {
    /// Checking for active internet connection
    if (await networkUtils.hasActiveInternet()) {
      isLoading = true;
      try {
        PromptResponseModel promptResponseModel = await repo.fetchPrompts(context);

        if (promptResponseModel.statusCode == 200 && promptResponseModel.result == true) {
          if(promptResponseModel.response !=null && promptResponseModel.response?.length !=0) {
            for(int i=0;i<promptResponseModel.response!.length;i++){
              promptTemplateIntentMapping[promptResponseModel.response![i].promptTemplate!] = promptResponseModel.response![i].intent!;
            }
            isLoading = false;
            print("weweweww promptTemplateIntentMapping ${promptTemplateIntentMapping}");
            notifyListeners();
          }
        } else {
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Something went wrong,Please try later'),
          ));
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(constants.genericErrorMsg),
        ));
        Util.instance
            .logMessage('Login Model', 'Error while authenticating $e');
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
