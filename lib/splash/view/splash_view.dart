import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/common_constants.dart' as constants;
import '../../utils/network_utils.dart';
import '../view_model/splash_view_model.dart';

class SplashScreenWidget extends StatefulWidget {
  const SplashScreenWidget({Key? key}) : super(key: key);

  @override
  State<SplashScreenWidget> createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
  late SplashViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<SplashViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// This will start tracking the current network status and give us
      /// information on the current status of the internet connection
      networkUtils.startTrackingConnection();
      viewModel.checkPermissionsAndNavigate(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage(constants.appIcon),
          width: constants.splashIconWidth,
          height: constants.splashIconHeight,
        ),
      ),
    );
  }
}
