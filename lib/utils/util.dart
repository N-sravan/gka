import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';

import 'app_state.dart';
import 'package:flutter/services.dart';
import 'common_constants.dart' as constants;
import '../login/model/department_user_permission_response.dart' as dept;

class Util {
  static Util? _instance;

  Util._();

  static Util get instance => _instance ??= Util._();

  Future<String> loadAsset(String fileName) async {
    return await rootBundle.loadString(fileName);
  }

  logMessage(String title, String message) {
    developer.log(
      'AIMS Log',
      name: title,
      error: message,
    );
  }

  fetchUserAssignedLocationHierarchyDept(
      dept.DepartmentUserPermissionsResponse userPermissionsResponse) async {
    if(userPermissionsResponse.response!.meta!.userDetails!.data!.location!.country != null) {
      List<dept.Country> countryData = userPermissionsResponse
          .response!.meta!.userDetails!.data!.location!.country!;
      for (int p = 0; p < countryData.length; p++) {
        AppState.instance.countryUUIDMapping
            .addAll({countryData[p].countryName!: countryData[p].countryUUID!});
        if (userPermissionsResponse.response!.meta!.userDetails!.data!
            .location!.country![p].state !=
            null) {
          List<dept.State> stateData = userPermissionsResponse
              .response!.meta!.userDetails!.data!.location!.country![p].state!;
          for (int i = 0; i < stateData.length; i++) {
            AppState.instance.stateUUIDMapping
                .addAll({stateData[i].stateName!: stateData[i].stateUUID!});
            if (userPermissionsResponse.response!.meta!.userDetails!.data!
                .location!.country![p].state![i].district !=
                null) {
              List<dept.District> districtData = userPermissionsResponse
                  .response!
                  .meta!
                  .userDetails!.data!.location!.country![p].state![i].district!;
              for (int j = 0; j < districtData.length; j++) {
                AppState.instance.districtUUIDMapping.addAll(
                    {
                      districtData[j].districtName!: districtData[j]
                          .districtUUID!
                    });
                if (userPermissionsResponse.response!.meta!.userDetails!.data!
                    .location!.country![p].state![i].district![i].block !=
                    null) {
                  List<dept.Block> blockData = userPermissionsResponse
                      .response!
                      .meta!
                      .userDetails!
                      .data!
                      .location!
                      .country![p]
                      .state![i]
                      .district![i]
                      .block!;
                  for (int k = 0; k < blockData.length; k++) {
                    AppState.instance.blockUUIDMapping
                        .addAll(
                        {blockData[k].blockName!: blockData[k].blockUUID!});
                    if (userPermissionsResponse
                        .response!
                        .meta!
                        .userDetails!
                        .data!
                        .location!
                        .country![p]
                        .state![i]
                        .district![i]
                        .block![i]
                        .panchayat !=
                        null) {
                      List<dept
                          .Panchayat> panchayatData = userPermissionsResponse
                          .response!
                          .meta!
                          .userDetails!
                          .data!
                          .location!
                          .country![p]
                          .state![i]
                          .district![i]
                          .block![i]
                          .panchayat!;
                      for (int j = 0; j < panchayatData.length; j++) {
                        AppState.instance.panchayatUUIDMapping.addAll({
                          panchayatData[k].panchayatName!: panchayatData[k]
                              .panchayatUUID!
                        });
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }


  AnimatedSwitcher iconSwitcher(IconData icon1, Color icon1Color, IconData icon2, Color icon2Color, bool switchIcon) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: child.key == const ValueKey('icon1')
              ? Tween<double>(begin: 1, end: 1).animate(anim)
              : Tween<double>(begin: 1, end: 1).animate(anim),
          child: ScaleTransition(scale: anim, child: child),
        ),
        child: switchIcon == false
            ? Icon(icon1, key: const ValueKey('icon1'), color: icon1Color)
            : Icon(icon2, key: const ValueKey('icon2'), color: icon2Color)
    );
  }

}
