// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:pin_code_fields/pin_code_fields.dart';
// import 'package:provider/provider.dart';
// import '../../../utils/common_constants.dart' as constants;
// import '../view_model/login_view_model.dart';
//
//
// class FarmerLoginScreenWidget extends StatefulWidget {
//   final String role;
//
//   const FarmerLoginScreenWidget({super.key, required this.role});
//
//   @override
//   State<FarmerLoginScreenWidget> createState() =>
//       _FarmerLoginScreenWidgetState();
// }
//
// class _FarmerLoginScreenWidgetState extends State<FarmerLoginScreenWidget> {
//   late LoginViewModel viewModel;
//
//   late bool _passwordVisible;
//   final TextEditingController _mobileNoController = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     viewModel = Provider.of<LoginViewModel>(context, listen: false);
//     _passwordVisible = false;
//     viewModel.getOtp = false;
//   }
//
//   void autoScroll() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       RenderBox box =
//       viewModel.otpKey.currentContext!.findRenderObject() as RenderBox;
//       Offset position =
//       box.localToGlobal(Offset.zero); //this is global position
//       double y = position.dy;
//       scrollController.animateTo(y,
//           duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<LoginViewModel>(
//       builder: (_, model, child) {
//         return WillPopScope(
//           onWillPop: () async {
//             Navigator.pop(context);
//             viewModel.clearAllData();
//             return true;
//           },
//           child: Material(
//             child: SafeArea(
//               child: Scaffold(
//                 backgroundColor: constants.primaryColor,
//                 resizeToAvoidBottomInset: true,
//                 body: SingleChildScrollView(
//                   child: Form(
//                     key: viewModel.formKey,
//                     child: SizedBox(
//                       height: MediaQuery.of(context).size.height,
//                       width: MediaQuery.of(context).size.width,
//                       child: Padding(
//                         padding: const EdgeInsets.all(constants.mediumPadding),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Expanded(
//                               flex: 2,
//                               child: Center(
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Container(
//                                       padding: const EdgeInsets.all(
//                                           constants.smallPadding),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(12),
//                                         color: Colors.white,
//                                       ),
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           Navigator.pop(context);
//                                         },
//                                         child: const Icon(
//                                           Icons.chevron_left,
//                                           size: constants.iconSizeLarge,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                         child: Image(
//                                           image: AssetImage(constants.loginImage),
//                                           fit: BoxFit.contain,
//                                         )),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               flex: 3,
//                               child: Column(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceEvenly,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                       constants.loginString,
//                                         style: constants.blackMont24W700,
//                                       ),
//                                       const SizedBox(
//                                           height: constants.verticalSpace10),
//                                       Text(
//                                         constants.loginDesc,
//                                         style: constants.grayMont14W500,
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     children: [
//                                       Container(
//                                         width:
//                                         MediaQuery.of(context).size.width,
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                           BorderRadius.circular(8.0),
//                                           border: Border.all(
//                                               color: const Color(0xff00A94E),
//                                               width: 1),
//                                           color: constants.inputFieldColor,
//                                         ),
//                                         child: TextFormField(
//                                           inputFormatters: [
//                                             LengthLimitingTextInputFormatter(
//                                                 10),
//                                             FilteringTextInputFormatter.allow(
//                                                 RegExp(r'^[1-9][0-9+]*')),
//                                           ],
//                                           keyboardType: TextInputType.phone,
//                                           autovalidateMode: AutovalidateMode
//                                               .onUserInteraction,
//                                           controller: _mobileNoController,
//                                           style: constants.black14W400,
//                                           decoration: InputDecoration(
//                                             filled: true,
//                                             fillColor: Colors.transparent,
//                                             hintText: constants
//                                                 .enterMobileNumber,
//                                             hintStyle: constants.grey14W400,
//                                             border: InputBorder.none,
//                                             focusedBorder: InputBorder.none,
//                                             errorStyle: const TextStyle(
//                                               color: Colors.redAccent,
//                                             ),
//                                             prefixIcon: Padding(
//                                               padding: const EdgeInsets.only(
//                                                   left: 8.0),
//                                               child: Text('+91 ',
//                                                   style: constants.black14W400),
//                                             ),
//                                             prefixIconConstraints:
//                                             const BoxConstraints(
//                                               minWidth: 0,
//                                             ),
//                                             // prefix: Text('+91 '),
//                                             prefixStyle: constants.black14W400,
//                                             contentPadding:
//                                             const EdgeInsets.symmetric(
//                                                 vertical: 14),
//                                           ),
//                                           validator: (value) {
//                                             viewModel.mobileNo = value;
//                                             if (viewModel.mobileNo == null ||
//                                                 viewModel.mobileNo!.isEmpty) {
//                                               return constants
//                                                   .emptyMobileNumberErrorMsg;
//                                             }
//                                             return null;
//                                           },
//                                           onSaved: (value) {
//                                             // final mobileNo = value?.replaceFirst('+91', '');
//                                             viewModel.formKey.currentState!
//                                                 .validate();
//                                           },
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                           height: constants.verticalSpace10),
//                                       GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             if (viewModel.formKey.currentState!
//                                                 .validate()) {
//                                               viewModel.generateOTP();
//                                             }
//                                           });
//                                         },
//                                         child: Align(
//                                           alignment: Alignment.bottomRight,
//                                           child: Text(
//                                             constants.generateOTP,
//                                             style: constants.generateOTPStyle,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   viewModel.getOtp
//                                       ? Column(
//                                     key: viewModel.otpKey,
//                                     children: [
//                                       Material(
//                                         type: MaterialType.transparency,
//                                         elevation: 0,
//                                         child: PinCodeTextField(
//                                           appContext: context,
//                                           pastedTextStyle:
//                                           constants.black14W400,
//                                           length: 4,
//                                           autoDisposeControllers: false,
//                                           backgroundColor:
//                                           Colors.transparent,
//                                           blinkWhenObscuring: false,
//                                           // animationType: AnimationType.fade,
//                                           validator: (v) {
//                                             v = v ?? "";
//                                             if (v.isEmpty) {
//                                               return constants.invalidEntry;
//                                             } else {
//                                               return null;
//                                             }
//                                           },
//                                           pinTheme: PinTheme(
//                                               shape:
//                                               PinCodeFieldShape.box,
//                                               borderRadius:
//                                               BorderRadius.circular(
//                                                   8),
//                                               fieldHeight: 56,
//                                               fieldWidth: 80,
//                                               activeFillColor:
//                                               Colors.white,
//                                               selectedColor: constants
//                                                   .inputFieldColor,
//                                               inactiveFillColor:
//                                               Colors.white,
//                                               selectedFillColor:
//                                               Colors.white,
//                                               activeColor: constants
//                                                   .inputFieldColor,
//                                               inactiveColor: constants
//                                                   .inputFieldColor),
//                                           cursorColor: constants
//                                               .continueButtonColor,
//                                           enableActiveFill: true,
//                                           keyboardType:
//                                           TextInputType.number,
//                                           inputFormatters: <TextInputFormatter>[
//                                             FilteringTextInputFormatter
//                                                 .digitsOnly
//                                           ],
//                                           boxShadows: const [
//                                             BoxShadow(
//                                               offset: Offset(0, 0),
//                                               color: Color(0xff00A94E),
//                                               blurRadius: 1,
//                                             )
//                                           ],
//                                           onCompleted: (v) {},
//                                           onChanged: (value) {
//                                             viewModel
//                                                 .updatedOTPValue(value);
//                                           },
//                                           beforeTextPaste: (text) {
//                                             return true;
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                       : const SizedBox(),
//                                   Align(
//                                     alignment: Alignment.bottomCenter,
//                                     child: SizedBox(
//                                       width: MediaQuery.of(context).size.width,
//                                       height: constants.newButtonHeight,
//                                       child: ElevatedButton(
//                                         onPressed: () async {
//                                           if (viewModel.formKey.currentState!
//                                               .validate()) {
//                                             if (viewModel.formKey.currentState!
//                                                 .validate()) {
//                                               /*bool? success =
//                                                               await viewModel
//                                                                   .verifyOTP(context);*/
//                                               bool? success = viewModel
//                                                   .validateOTP(context);
//                                               if (success != null &&
//                                                   success == true) {
//                                                 Navigator.pushNamed(
//                                                     context, constants.homeRoute);
//                                               /*  Navigator.push(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                         const HomeScreenWidget()));*/
//                                               } else {
//                                                 Fluttertoast.showToast(
//                                                     msg: 'Enter Valid OTP',
//                                                     toastLength:
//                                                     Toast.LENGTH_LONG);
//                                               }
//                                             }
//                                           }
//                                         },
//                                         style: ElevatedButton.styleFrom(
//                                           fixedSize: Size(MediaQuery.of(context).size.height,
//                                               constants.splashButtonHeight),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                             BorderRadius.circular(constants.borderRadius),
//                                           ),
//                                           backgroundColor: constants.splashButtonBg,
//                                         ),
//                                         child: Text(
//                                          constants.verifyOtpString,
//                                           style: constants.whiteMont14W600,
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
