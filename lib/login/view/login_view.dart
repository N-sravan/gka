import 'package:flutter/material.dart';
import 'package:gka/home/view/home_view.dart';
import 'package:provider/provider.dart';
import 'package:gka/utils/common_constants.dart' as constants;
import '../../utils/network_utils.dart';
import '../view_model/login_view_model.dart';
import '../../login/model/department_user_permission_response.dart' as response;

class LoginScreenWidget extends StatefulWidget {
  const LoginScreenWidget({super.key});

  @override
  State<LoginScreenWidget> createState() => _LoginScreenWidgetState();
}

class _LoginScreenWidgetState extends State<LoginScreenWidget> {
  late LoginViewModel viewModel;
  final _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  response.Meta data = response.Meta(
    userId: "b7a7ca67-6fd3-4f2e-97c6-b9b84fdbd7da",
    username: "kerala_ao",
    firstName: "Aswin",
    lastName: "Kumar",
    email: "keralaao@gmail.com",
    mobileNo: "+919889786767",
    userDetails: response.UserDetails(
      data: response.Data(
          locType: "Panchayat",
          location: response.Location(country: [
            response.Country(
                countryName: "INDIA",
                countryUUID: "d6b37905-d2d3-4275-9317-d9b6f47cd783",
                state: [
                  response.State(
                      stateName: "KERALA",
                      stateUUID: "62d3dc99-5bc3-4303-8be1-d4fa1f7deee5",
                      district: [
                        response.District(
                            districtName: "Palakkad",
                            districtUUID:
                                "1270f554-20cc-43ee-803e-1532f00e047c",
                            block: [
                              response.Block(
                                  blockName: "Sreekrishnapuram",
                                  blockUUID:
                                      "db64691f-a7de-4e88-b5af-ecbe4dc6d191",
                                  panchayat: [
                                    response.Panchayat(
                                        panchayatName: "Karimpuzha",
                                        panchayatUUID:
                                            "0ec4c732-5db9-4a3e-896a-f7baf24b2966")
                                  ])
                            ])
                      ])
                ])
          ])),
      scope: null,
    ),
    createdTs: null,
    updatedTs: null,
    lastLoginTs: "2024-03-11T10:45:55.398+00:00",
    status: true,
    title: null,
    customerId: "931e0a8e-54e9-49f4-87db-d6e1fe350432",
    customerName: "keralacustomer",
    customAttributes: null,
  );

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<LoginViewModel>(context, listen: false);
    _usernameController.text = "kerala_ao";
    _passwordController.text = "agri123";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// This will start tracking the current network status and give us
      /// information on the current status of the internet connection
      networkUtils.startTrackingConnection();
      // viewModel.checkPermissionsAndNavigate(context);
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
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: constants.primaryColor,
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
                              /* GestureDetector(
                                  onTap: () {
                                    if (!model.isLoading) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  )),*/
                              const SizedBox(
                                height: constants.buttonHeight,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(constants.smallPadding),
                                child: Center(
                                  child: SizedBox(
                                    height: constants.loginIconHeight,
                                    width: constants.loginIconWidth,
                                    child: Image(
                                      image: AssetImage(constants.appIcon),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                constants.loginto,
                                style: constants.darkblue20W600,
                              ),
                              const SizedBox(
                                height: constants.largePadding,
                              ),
                              Text(
                                constants.userNameString,
                                style: constants.grey16W400,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0,
                                    constants.xSmallPadding,
                                    0.0,
                                    constants.mediumPadding),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    // Set your desired border radius
                                    color: constants
                                        .inputFieldColor, // Background color
                                  ),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _usernameController,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.transparent,
                                      hintText: constants.enterUserName,
                                      hintStyle: constants.grey16W400,
                                      focusedBorder: InputBorder.none,
                                      border: InputBorder.none,
                                      errorStyle: const TextStyle(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return constants.emptyUsernameErrorMsg;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _formKey.currentState!.validate();
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                constants.passwordString,
                                style: constants.grey16W400,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0,
                                    constants.xSmallPadding,
                                    0.0,
                                    constants.mediumPadding),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    // Set your desired border radius
                                    color: constants
                                        .inputFieldColor, // Background color
                                  ),
                                  child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _passwordController,
                                    obscureText: !_passwordVisible,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    style: const TextStyle(color: Colors.black),
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        hintText: constants.enterPassword,
                                        hintStyle: constants.grey16W400,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _passwordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _passwordVisible =
                                                  !_passwordVisible;
                                            });
                                          },
                                        ),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none),
                                        errorStyle: const TextStyle(
                                          color: Colors.redAccent,
                                        )),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return constants.emptyPasswordErrorMsg;
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _formKey.currentState!.validate();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(constants.mediumPadding),
                      child: model.isLoading
                          ? const Padding(
                              padding: EdgeInsets.fromLTRB(
                                  0.0,
                                  constants.largePadding,
                                  0.0,
                                  constants.mediumPadding),
                              child: CircularProgressIndicator(
                                color: Colors.black,
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
                                      /// Data entered in the form is valid, continue to login
                                      String userId = _usernameController.text;
                                      String password =
                                          _passwordController.text;
                                      /*  viewModel.authenticate(
                                          userId, password, context);*/
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreenWidget(
                                                      data: data)));
                                    }
                                  },
                                  style: constants.buttonStyle,
                                  child: Text(
                                    constants.loginString,
                                    style: constants.white16W500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
