import 'package:flutter/material.dart';
import '../utils/common_constants.dart' as constants;

class NavigationUtil {
  static NavigationUtil? _instance;

  NavigationUtil._();

  static NavigationUtil get instance => _instance ??= NavigationUtil._();

  navigateToRoleScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, constants.roleRoute, (route) => false);
  }


  navigateToLoginScreen(BuildContext context, String role) {
    Navigator.pushNamed(
      context,
      constants.loginRoute,
      arguments: role,
    );
  }

  navigateToFarmerLoginScreen(BuildContext context, String role) {
    Navigator.pushNamed(
      context,
      constants.farmerLoginRoute,
      arguments: role,
    );
  }

  navigateToDepartmentLoginScreen(BuildContext context, String role) {
    Navigator.pushNamed(
      context,
      constants.departmentLoginRoute,
      arguments: role,
    );
  }

  navigateToHomeScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
        context, constants.homeRoute, (route) => false);
  }

}
