import 'package:flutter/material.dart';
import 'package:gka/utils/app_state.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../../chat_window.dart';
import '../../utils/network_utils.dart';
import '../view_model/login_view_model.dart';

class LoginScreenWidget extends StatefulWidget {
  final String? role;

  const LoginScreenWidget({super.key, this.role});

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  late LoginViewModel viewModel;
  final _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String appIcon = '';

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<LoginViewModel>(context, listen: false);

    switch (constants.projectId) {
      case constants.apwrimsUUID:
        _usernameController.text = "tapranauser";
        _passwordController.text = "fieldwise@123";
        appIcon = constants.appIcon;
        break;
      case constants.gowaterUUID:
        _usernameController.text = "tapranauser";
        _passwordController.text = "fieldwise@123";
        appIcon = constants.appIcon;

        break;
      case constants.kaleswaramUUID:
        _usernameController.text = "Sandeep";
        _passwordController.text = "test123";
        appIcon = constants.fieldRishiIcon;

        break;
      case constants.tnwrimsUUID:
        _usernameController.text = "Pradeep";
        _passwordController.text = "test123";
        appIcon = constants.fieldRishiIcon;

        break;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      networkUtils.startTrackingConnection();
    });
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginViewModel>(
      builder: (_, model, child) {
        return SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Form(
              key: _formKey,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(constants.fieldRishiBgIcon),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: constants.primaryColor.withOpacity(0.8),
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(constants.mediumPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 120,
                                  ),
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(
                                            constants.smallPadding),
                                        child: Center(
                                          child: SizedBox(
                                            height: 66,
                                            child: Image(
                                              image: AssetImage(
                                                  constants.fieldRishiIcon),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'fieldRISHI:',
                                        style: TextStyle(
                                          fontFamily: 'OpenSans',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 30,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'GenAI Co-Pilot for AgriExpert Advisory...',
                                        style: TextStyle(
                                          fontFamily: 'OpenSans',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 60),
                                  Card(
                                    color: const Color(0XFF55A18F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            constants.userNameString,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0,
                                                constants.xSmallPadding,
                                                0.0,
                                                constants.mediumPadding),
                                            child: Container(
                                              height: 44,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: Colors
                                                    .white, // Input field color
                                              ),
                                              child: TextFormField(
                                                keyboardType:
                                                    TextInputType.text,
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                controller: _usernameController,
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  hintText:
                                                      constants.enterUserName,
                                                  hintStyle:
                                                      constants.grey14W500,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  border: InputBorder.none,
                                                  errorStyle: const TextStyle(
                                                      color: Colors.redAccent),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return constants
                                                        .emptyUsernameErrorMsg;
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) {
                                                  _formKey.currentState!
                                                      .validate();
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            constants.passwordString,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0,
                                                constants.xSmallPadding,
                                                0.0,
                                                constants.mediumPadding),
                                            child: Container(
                                              height: 44,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                color: Colors
                                                    .white, // Input field color
                                              ),
                                              child: TextFormField(
                                                autovalidateMode:
                                                    AutovalidateMode
                                                        .onUserInteraction,
                                                controller: _passwordController,
                                                obscureText: !_passwordVisible,
                                                enableSuggestions: false,
                                                autocorrect: false,
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.transparent,
                                                  hintText:
                                                      constants.enterPassword,
                                                  hintStyle:
                                                      constants.grey14W500,
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      _passwordVisible
                                                          ? Icons.visibility
                                                          : Icons
                                                              .visibility_off,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _passwordVisible =
                                                            !_passwordVisible;
                                                      });
                                                    },
                                                  ),
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  errorBorder:
                                                      const UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none),
                                                  errorStyle: const TextStyle(
                                                      color: Colors.redAccent),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return constants
                                                        .emptyPasswordErrorMsg;
                                                  }
                                                  return null;
                                                },
                                                onSaved: (value) {
                                                  _formKey.currentState!
                                                      .validate();
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 40),
                                          model.isLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: double.infinity,
                                                  height:
                                                      constants.buttonHeight,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        // Data entered in the form is valid, continue to login
                                                        String userId =
                                                            _usernameController
                                                                .text;
                                                        String password =
                                                            _passwordController
                                                                .text;
                                                        if (userId.isNotEmpty &&
                                                            password
                                                                .isNotEmpty) {
                                                          bool? result =
                                                              await viewModel
                                                                  .authenticate(
                                                                      userId,
                                                                      password,
                                                                      context);
                                                          if (result) {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ChatWindow(
                                                                  isFromHistory:
                                                                      false,
                                                                  sessionId: AppState
                                                                      .instance
                                                                      .sessionId,
                                                                ),
                                                              ),
                                                            );
                                                            print(
                                                                "authentication success - ${AppState.instance.sessionId}");
                                                          }
                                                        }
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: Colors.white,
                                                      // Button color
                                                      onPrimary:
                                                          Color(0XFF5999F2),
                                                      // Button text color
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      constants.loginString,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0XFF55A18F),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        /*Container(
                          padding:
                              const EdgeInsets.all(constants.mediumPadding),
                          child: model.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      0.0,
                                      constants.largePadding,
                                      0.0,
                                      constants.mediumPadding),
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0,
                                      constants.largePadding,
                                      0.0,
                                      constants.mediumPadding),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: constants.buttonHeight,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          // Data entered in the form is valid, continue to login
                                          String userId =
                                              _usernameController.text;
                                          String password =
                                              _passwordController.text;
                                          if (userId.isNotEmpty &&
                                              password.isNotEmpty) {
                                            bool? result =
                                                await viewModel.authenticate(
                                                    userId, password, context);
                                            if (result) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatWindow(
                                                    isFromHistory: false,
                                                    sessionId: AppState
                                                        .instance.sessionId,
                                                  ),
                                                ),
                                              );
                                              print(
                                                  "authentication success - ${AppState.instance.sessionId}");
                                            }
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(
                                          MediaQuery.of(context).size.height,
                                          constants.splashButtonHeight,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              constants.borderRadius),
                                        ),
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: Text(
                                        constants.loginString,
                                        style: constants.white16W500,
                                      ),
                                    ),
                                  ),
                                ),
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
