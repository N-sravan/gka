
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../utils/common_constants.dart' as constants;
import '../../utils/util.dart';
import '../view_model/login_view_model.dart';

class RoleSelectionWidget extends StatefulWidget {
  const RoleSelectionWidget({Key? key}) : super(key: key);

  @override
  State<RoleSelectionWidget> createState() => _RoleSelectionWidgetState();
}

class _RoleSelectionWidgetState extends State<RoleSelectionWidget> {
  late LoginViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<LoginViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(builder: (_, model, child) {
      return Scaffold(
        backgroundColor: constants.roleScreenBg,
        body: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(constants.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          constants.appTitle,
                          style: constants.green32W600,
                        ),
                        SvgPicture.asset(
                          constants.roleScreenIcon,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            constants.loginAs,
                            style: constants.blackMont19W700,
                          ),
                        ],
                      ),
                      const SizedBox(height: constants.verticalSpace20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          roleWidget(constants.farmer, constants.farmerRole,
                              viewModel.selectedRole == constants.farmer),
                          roleWidget(
                              constants.department,
                              constants.departmentRole,
                              viewModel.selectedRole == constants.department),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (viewModel.selectedRole.isNotEmpty) {
                            viewModel.navigationBasedOnRole(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(MediaQuery.of(context).size.height,
                              constants.splashButtonHeight),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(constants.borderRadius),
                          ),
                          backgroundColor: constants.splashButtonBg,
                        ),
                        child: Text(
                          'Login',
                          style: constants.whiteMont14W600,
                        ),
                      ),
                      const SizedBox(height: constants.verticalSpace10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            constants.dontHaveAccount,
                            style: constants.black16W400,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              constants.register,
                              style: constants.greenMont16W700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget roleWidget(String title, String imagePath, bool isSelected) {
    return GestureDetector(
      onTap: () {
        viewModel.roleSelection(title, context);
      },
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: isSelected
                      ? Border.all(
                      color: constants.selectedRoleBorderColor, width: 2)
                      : Border.all(
                      color: constants.defaultRoleBorderColor, width: 2),
                  borderRadius: BorderRadius.circular(constants.borderRadius),
                  color: isSelected ? constants.roleSelectedColor : null),
              child: Padding(
                padding: const EdgeInsets.all(constants.smallPadding),
                child: SvgPicture.asset(
                  imagePath,
                ),
              ),
            ),
            const SizedBox(height: constants.verticalSpace5),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: constants.blackMont12W500,
            ),
          ],
        ),
      ),
    );
  }
}
