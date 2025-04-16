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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /// This will start tracking the current network status and give us
      /// information on the current status of the internet connection
      await networkUtils.startTrackingConnection();
      await viewModel.checkPermissionsAndNavigate(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashViewModel>(
      builder: (_, model, child) {
        if (model.isLoading) {
          return child!;
        }

        return viewModel.noInternet
            ? Scaffold(
                body: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(constants.mediumPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "You are Offline",
                          style: constants.red12W500,
                        ),
                        const SizedBox(height: constants.verticalSpace10),
                        Text(
                          "You are not connected to the internet. Please connect to the internet and try again",
                          style: constants.black16W500,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const Center(
                child: Image(
                  image: AssetImage(constants.appIcon),
                  width: constants.splashIconWidth,
                  height: constants.splashIconHeight,
                ),
              );
      },
    );
  }
}
