import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/common_constants.dart' as constants;
import '../view_model/permissions_view_model.dart';

class PermissionsScreenWidget extends StatefulWidget {
  const PermissionsScreenWidget({Key? key}) : super(key: key);

  @override
  State<PermissionsScreenWidget> createState() =>
      _PermissionsScreenWidgetState();
}

class _PermissionsScreenWidgetState extends State<PermissionsScreenWidget> {
  late PermissionsViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<PermissionsViewModel>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PermissionsViewModel>(builder:  (_, model, child) {
      return SafeArea(
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: constants.primaryColor,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: constants.permissionScreenTopBarHeight,
                          color: constants.primaryColor,
                          alignment: Alignment.bottomCenter,
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(
                                0.0,
                                constants.largePadding * 1.5,
                                0.0,
                                constants.smallPadding),
                            child: SizedBox(
                              height: constants.splashIconHeight,
                              width: constants.splashIconHeight,
                              child: Image(
                                image: AssetImage(constants.appIcon),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                              constants.largePadding,
                              constants.largePadding * 1.5,
                              constants.largePadding,
                              constants.largePadding),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(
                                    0.0, 0.0, constants.mediumPadding, 0.0),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: constants.buttonColor,
                                  size: constants.permissionIconDimension,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 0.0, 0.0, constants.smallPadding),
                                      child: Text(
                                        constants.locationPermissionHeading,
                                        style: constants.black16W500,
                                      ),
                                    ),
                                    Text(
                                      constants.locationPermissionSubHeading,
                                      style: constants.black14W400,
                                      maxLines: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            constants.largePadding,
                            0.0,
                            constants.largePadding,
                            constants.largePadding,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(
                                    0.0, 0.0, constants.mediumPadding, 0.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: constants.buttonColor,
                                  size: constants.permissionIconDimension,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 0.0, 0.0, constants.smallPadding),
                                      child: Text(
                                        constants.cameraPermissionHeading,
                                        style: constants.black16W500,
                                      ),
                                    ),
                                    Text(
                                      constants.cameraPermissionSubHeading,
                                      style: constants.black14W400,
                                      maxLines: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            constants.largePadding,
                            0.0,
                            constants.largePadding,
                            constants.largePadding,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(
                                    0.0, 0.0, constants.mediumPadding, 0.0),
                                child: Icon(
                                  Icons.mic_rounded,
                                  color: constants.buttonColor,
                                  size: constants.permissionIconDimension,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 0.0, 0.0, constants.smallPadding),
                                      child: Text(
                                        constants
                                            .microPhonePermissionHeading,
                                        style: constants.black16W500,
                                      ),
                                    ),
                                    Text(
                                      constants
                                          .microPhonePermissionSubHeading,
                                      style: constants.black14W400,
                                      maxLines: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child:  model.isLoading
                      ?  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0.0,
                        constants.largePadding,
                        0.0,
                        constants.mediumPadding),
                    child: constants.indicatorBlack,
                  )
                      : Padding(
                    padding: const EdgeInsets.fromLTRB(
                        0.0, 0.0, 0.0, constants.mediumPadding),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: constants.formButtonBarHeight,
                      child: Padding(
                        padding: const EdgeInsets.all(constants.mediumPadding),
                        child: SizedBox(
                          height: constants.buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              viewModel.requestPermissionsAndNavigate(context);
                            },
                            style: constants.buttonStyle,
                            child: Text(
                              constants.allowPermissions,
                              style: constants.buttonTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
