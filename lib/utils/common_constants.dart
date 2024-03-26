import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// Shared Preferences
const String preferenceTypeString = 'string';
const String preferenceTypeStringList = 'stringList';
const String preferenceTypeInt = 'int';
const String preferenceTypeBool = 'bool';
const String preferenceTypeDouble = 'double';
const String preferenceIsLoggedIn = 'isLoggedIn';
const String preferenceLoginAttempts = 'loginAttempts';
const String preferenceLastLoginTime = 'lastLoginAttemptTime';
const String preferenceUserSelectedFarm = 'farmSelected';
const String preferenceOwnerInfoTypeBool = 'bool';

/*//Date Formats
final DateFormat yearMonthDayFormat = DateFormat('yyyy-MM-dd');
final DateFormat dayMonthYearFormat = DateFormat('dd-MM-yyyy');*/

// Secured storage keys
const String preferenceUserName = 'userName';
const String preferenceUserEmail = 'userEmail';
const String preferenceUserFirstName = 'userFirstName';
const String preferenceUserMobileNo = 'userMobileNo';
const String preferenceUserId = 'userId';
const String preferenceToken = 'token';
const String preferenceRefreshToken = 'refreshToken';
const String preferenceCsrfToken = 'csrfToken';
const String preferenceUserRole = 'userRole';
const String preferenceUserState = 'userState';
const String preferenceUserStateUUID = 'stateUUID';
const String preferenceUserDistrict = 'userDistrict';
const String preferenceUserDistrictUUID = 'districtUUID';
const String hiveEncryptionKey = 'hiveKey';


// HeaderKeys
const String accept = 'Accept';
const String approve = 'Approve';
const String reject = 'Reject';
const String headerJson = 'application/json';
const String headerMultipart = 'multipart/form-data';

const String headerContentType = 'Content-Type';
const String headerContentTypeFormUrl = 'application/x-www-form-urlencoded';
const String userName = 'username';
const String password = 'password';
const String clientId = 'client_id';
const String grantType = 'grant_type';
const String agriwiseClient = 'agriwiseclient';
const String headerRefeshToken = 'refresh_token';

// Icons
const String appIcon = 'assets/images/flutter_logo.png';

// URLs
const String baseUrl = 'https://keralakrishistack.vassarlabs.com/';
// const String baseUrl = 'https://agriwise.vassarlabs.com/';
// const String krishidsBaseUrl = 'http://acerkrishidss.vassarlabs.com/staging/api';
// const String krishidsBaseUrl = 'https://agriwise.vassarlabs.com/staging/api';
const String imageUploadUrl = 'https://agriwise.vassarlabs.com/agribot/bucket/insert_file';
const String geoJsonSurveyPointsUrl ='http://acerkrishidss.vassarlabs.com/geoserver/krishidss/wms?service=WMS&version=1.1.0&request=GetMap&layers=krishidss%3Atemp_farm_meta_data&bbox=-180.0%2C-90.0%2C180.0%2C90.0&width=768&height=384&format=geojson&cql_filter=';
/*const String krishidsBaseUrl =
    'http://agriwise.vassarlabs.com/api';*/    //-

const String loginEndpoint =
    'auth/realms/agriwiserealm/protocol/openid-connect/token';
const String logoutEndpoint =
    'auth/realms/agriwiserealm/protocol/openid-connect/logout';
const String csrfEndPoint = 'um/generate-csrf-token';
const String userPermissionsEndPoint = 'um/user-permissions/';
const String submittedImageBaseUrl =
    'http://acerkrishidss.vassarlabs.com/pa/images/';
const String submittedImagePath = '/pictorialAnalysisData/rawImages/';
const String submitImageEndPoint = '/pictorialAnalysisData/rawImages/';


//UUIDs & keys

const String indiaUUID = 'd6b37905-d2d3-4275-9317-d9b6f47cd783';
const String keralaStateUUID = '62d3dc99-5bc3-4303-8be1-d4fa1f7deee5';
// const String appUUID = '62feedb6-024d-4c3e-bd9e-5d4ee96a5d9d';
const String appUUID = '1516fd33-c918-4ee6-92a1-445a02977a9b';
const String countryKey = 'COUNTRY';
const String stateKey = 'STATE';
const String districtKey = 'DISTRICT';
const String blockKey = 'BLOCK';
const String panchayatKey = 'PANCHAYAT';
const String villageKey = 'VILLAGE';
const String farmKey = 'FARM';
const String pointKey = 'POINT';

// Login API response keys
const String loginResultKey = 'result';

// Paddings
const double largePadding = 32;
const double mediumPadding = 16;
const double smallPadding = 8;
const double xSmallPadding = 4;

// Dimensions
const double splashIconHeight = 150;
const double splashIconWidth = 120;
const double departmentIconTop=134;
const double buttonHeight = 46;
const double minButtonHeight = 32;
const double mediumButtonHeight = 38;
const double buttonHeightFarmer = 66;
const double permissionScreenTopBarHeight = 175;
const double permissionIconDimension = 46;
const double formButtonBarHeight = 82;
const double loginIconHeight = 166;
const double loginIconWidth = 144;
const double boxHeight = 56;
const double appDrawerHeaderHeight = 150;
const double closeIconDimension = 16;
const double cameraIconDimension = 36;
const double cameraPlaceholderImageHeight = 220;
const double networkImageErrorPlaceholderWidth = 160;

// Elevations
const double appBarElevation = 4;
const double formComponentsElevation = 4;

// Time durations
const int splashDuration = 2; // Seconds
const int lockoutTime = 900; // Seconds

const int lockoutAttempts = 10;

const int thresholdDistance = 5;

const int imageSubmissionRetryCount = 2;
const int imageDeletionRetryCount = 2;

// Colors
// const Color primaryColor = Color(0xF5F5F5);
const Color primaryColor = Color.fromRGBO(248, 248, 250, 1);
const Color secondaryColor = Color.fromRGBO(118, 118, 128, 0.12);
const Color primaryBgColor = Color(0xffF8F8FA);
const Color containerColor=Color.fromRGBO(118, 118, 128, 0.12);
const Color labelColor=Color.fromRGBO(255, 255, 255, 1);
const Color mapIconsHighlightColor = Color(0xFF7FD749);
const Color mapIconsDefaultColor = Color(0xFF1D1F24);
// const Color buttonColor = Color(0xFF6C9E64);
const Color buttonColor = Color(0xFF6C9E64);
const Color textColorGreen = Color(0xFF28A745);
const Color lightBlack = Color(0xFF1C1E24);

const Color darkGrey = Color(0xFF858993);
const Color lightGrey = Color(0xFFC3C5CB);
const Color grey = Color(0xFF666B77);
const Color lightGrey3 = Color(0xFFf0eded);
const Color grey25OP = Color(0x26767680);
const Color lightGrey2 = Color(0xFFA4A8B0);
const Color lightRed = Color(0x66FF2E2E);
const Color darkRed = Color(0x66db0b0b);
const Color primaryGreen = Color(0xFF7FD649);
const Color secondaryGreen = Color(0xFF6C9E64);
const Color hintTextColor = Color(0xFF666B77);
const Color dropdownBackground = Color(0xFF2B2E36);
const Color dropdownFontColor = Color(0xFFB3B6BD);
const Color submitButtonColor = Color(0xFF6C9E64);
const Color continueButtonColor = Color(0xFF4BA164);
const Color radioButtonActiveColor = Color(0xFF4BA164);
const Color blackColor = Colors.black;
const Color disabledColor = Color(0xFFA4A8B0);
const Color buttonDisabledColor = Color(0x39E0FCEB);
const Color lightWhite = Color(0xFFB3B6BD);
const Color darkBlue =  Color.fromRGBO(6, 32, 64, 1);
const Color inputFieldColor =Color.fromRGBO(118, 118, 128, 0.12);
const Color tableValueColor = Color(0xFF515466);



// Crop Colors
const Color paddyColor = Color(0xFF4BA164);

TextStyle normalBlackTextStyle = const TextStyle(
  fontSize: 16,
  color: Colors.black,
);

TextStyle mediumGreyTextStyle = const TextStyle(
  fontSize: 14,
  color: lightGrey,
);

TextStyle buttonTextStyle = const TextStyle(
  fontSize: 18,
  color: Colors.white,
  fontWeight: FontWeight.w500,
);

TextStyle white32W600 = const TextStyle(
  color: Colors.white,
  fontSize: 32,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w600,
);

TextStyle green32W600 = const TextStyle(
  color: textColorGreen,
  fontSize: 32,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w600,
);


/*TextStyle green14W500 = const TextStyle(
  color: Color(0XFF4BA164),
  fontSize: 14,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);*/


TextStyle greenCB16W500 = const TextStyle(
  color: Color(0xFF4BA164),
  fontSize: 16,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

TextStyle greenCB14W300 = const TextStyle(
  color: Color(0xFF4BA164),
  fontSize: 14,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400,
);

TextStyle green14W500 = const TextStyle(
  color: Color.fromRGBO(75, 161, 100, 1),
  fontSize: 14,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

TextStyle green12W500 = const TextStyle(
  color: Color.fromRGBO(75, 161, 100, 1),
  fontSize: 12,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

TextStyle lightGrey16W400 = const TextStyle(
  color: lightGrey,
  fontSize: 16,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);

// TextStyle lightGrey16W400 = const TextStyle(
//   color: Colors.black,
//   fontSize: 20,
//   fontFamily: 'Roboto',
//   fontWeight: FontWeight.w600,
// );

TextStyle grey14W500 = const TextStyle(
  fontFamily: "Roboto",
  fontWeight: FontWeight.w500,
  fontSize: 14.0,
  color: Colors.grey,
);

TextStyle grey14W400 = const TextStyle(
  fontFamily: "Poppins",
  fontWeight: FontWeight.w400,
  fontSize: 14.0,
  color: Colors.grey,
);

TextStyle grey12W400 = const TextStyle(
  fontFamily: "Poppins",
  fontWeight: FontWeight.w400,
  fontSize: 13.0,
  color: Colors.grey,
);

TextStyle gray24W500= const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 24.0,
    color: Color.fromRGBO(29, 31, 36, 1)
);

TextStyle black14W400 = const TextStyle(
  color: Colors.black,
  fontSize: 14,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400,
);

TextStyle black14W600 = const TextStyle(
  color: Colors.black,
  fontSize: 14,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w600,
);

TextStyle black14W500 = const TextStyle(
  color: Colors.black,
  fontSize: 14,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle black12W400 = const TextStyle(
  color: Colors.black,
  fontSize: 12,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);

TextStyle black16W400 = const TextStyle(
  color: Colors.black,
  fontSize: 14,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400,
);

TextStyle black16W500 = const TextStyle(
  color: Colors.black,
  fontSize: 16,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

TextStyle black20W600 = const TextStyle(
  color: Colors.black,
  fontSize: 20,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w600,
);

TextStyle black18W600 = const TextStyle(
  color: Colors.black,
  fontSize: 18,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w600,
);

TextStyle black20W400 = const TextStyle(
  color: blackColor,
  fontSize: 20,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);

TextStyle roBlack16W500 = const TextStyle(
  color: blackColor,
  fontSize: 16,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle darkblue20W600 = const TextStyle(
  color: darkBlue,
  fontSize: 20,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w600,
);


TextStyle darkGrey20W400 = const TextStyle(
  color: darkGrey,
  fontSize: 20,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);

TextStyle disabledDarkGrey20W400 = const TextStyle(
  color: disabledColor,
  fontSize: 20,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);
TextStyle disabledDarkGrey16W500 = const TextStyle(
  color: disabledColor,
  fontSize: 16,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle grey16W400 = const TextStyle(
  color: grey,
  fontSize: 16,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);

TextStyle grey16W500 = const TextStyle(
  color: grey,
  fontSize: 16,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

TextStyle poWhite12W500 = const TextStyle(
  color: Colors.white,
  fontSize: 12,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

TextStyle poTableValue12W400 = const TextStyle(
  color: tableValueColor,
  fontSize: 12,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400,
);

TextStyle white16W500 = const TextStyle(
  color: Colors.white,
  fontSize: 16,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

// Text Styles
TextStyle white24W500 = const TextStyle(
    fontFamily: "Roboto",
    fontWeight: FontWeight.w500,
    fontSize: 24.0,
    color: lightWhite);

TextStyle lightWhite14W500 = const TextStyle(
  fontFamily: "Roboto",
  fontWeight: FontWeight.w500,
  fontSize: 14.0,
  color: lightWhite,
);

TextStyle green14W400 = const TextStyle(
  fontFamily: "Roboto",
  fontWeight: FontWeight.w400,
  fontSize: 14.0,
  color: primaryGreen,
);

TextStyle green16W500 = const TextStyle(
  fontFamily: "Roboto",
  fontWeight: FontWeight.w500,
  fontSize: 16.0,
  color: primaryGreen,
);

TextStyle darkGreen16W500 = const TextStyle(
  fontFamily: "Poppins",
  fontWeight: FontWeight.w500,
  fontSize: 16.0,
  color: continueButtonColor,
);

TextStyle redPop16W500 = const TextStyle(
  fontFamily: "Poppins",
  fontWeight: FontWeight.w500,
  fontSize: 16.0,
  color: lightRed,
);

TextStyle appBarHeaderTextStyle = const TextStyle(
  fontSize: 22,
  color: Colors.white,
  fontWeight: FontWeight.w500,
);

TextStyle appBarSubHeaderTextStyle = const TextStyle(
  fontSize: 14,
  color: Colors.white,
  fontWeight: FontWeight.w500,
);

TextStyle appBarListTileTextStyle = const TextStyle(
  fontSize: 16,
  color: Colors.black,
  fontWeight: FontWeight.w400,
);

TextStyle lightGrey2_14W400 = const TextStyle(
  fontFamily: "Roboto",
  fontWeight: FontWeight.w400,
  fontSize: 14.0,
  color: lightGrey2,
);

TextStyle white14W500 = const TextStyle(
  fontFamily: "Roboto",
  fontWeight: FontWeight.w500,
  fontSize: 14.0,
  color: Colors.white,
);

TextStyle red14W500 = const TextStyle(
  color: lightRed,
  fontSize: 14,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle red12W500 = const TextStyle(
  color: lightRed,
  fontSize: 12,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

TextStyle red16W500 = const TextStyle(
  color: lightRed,
  fontSize: 16,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle darkRed12W200 = const TextStyle(
  color: Colors.red,
  fontSize: 12,
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

// Button Styles
ButtonStyle buttonStyle = ElevatedButton.styleFrom(
  // backgroundColor: buttonColor,
  backgroundColor: Colors.blue,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  elevation: formComponentsElevation,
);

/*IconStyleData dropDownIconStyle = const IconStyleData(
  icon: Icon(
    Icons.keyboard_arrow_down_rounded,
  ),
  iconSize: 20,
  iconEnabledColor: hintTextColor,
  iconDisabledColor: hintTextColor,
);*/

/*MenuItemStyleData dropDownMenuItemStyle = const MenuItemStyleData(
  height: 30,
  padding: EdgeInsets.only(left: 14, right: 14),
);*/

//Decoration
ShapeDecoration shapeDecorationRadius8 = ShapeDecoration(
  color: lightBlack,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
);

// Disabled Decoration
ShapeDecoration disabledShapeDecorationRadius8 = ShapeDecoration(
  color: const Color.fromRGBO(118, 118, 128, 0.12),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
);

BoxDecoration networkImageContainerDecoration = BoxDecoration(
  border: Border.all(
    color: Colors.white,
  ),
  borderRadius: const BorderRadius.all(
    Radius.circular(10),
  ),
  color: Colors.white,
);

//Indicator
Widget indicator = const Center(
  child: CircularProgressIndicator(
    strokeWidth: 5,
    color: Colors.black,
  ),
);

Widget indicatorWhite = const Center(
  child: CircularProgressIndicator(
    strokeWidth: 5,
    color: Colors.white,
  ),
);

Widget indicatorBlack = const Center(
  child: CircularProgressIndicator(
    strokeWidth: 5,
    color: Colors.black,
  ),
);

OutlineInputBorder formFieldBorder = OutlineInputBorder(
    borderSide: const BorderSide(color: Color(0xFF3A3E49), width: 2),
    borderRadius: BorderRadius.circular(14));

OutlineInputBorder chatBotTextFieldBorder = OutlineInputBorder(
  borderSide: const BorderSide(color: continueButtonColor, width: 2),
  borderRadius: BorderRadius.circular(20),
);

const TextStyle hintTextStyle = TextStyle(
  fontFamily: "Roboto",
  fontWeight: FontWeight.w500,
  fontSize: 16.0,
  color: hintTextColor,
);

//Strings
const String locationPermissionHeading = 'Location';
const String locationPermissionSubHeading =
    'Allow location permission to fetch '
    'the current location. Please make sure your \'Location services\' are turned on.';
const String cameraPermissionHeading = 'Camera';
const String cameraPermissionSubHeading = 'Allow camera permission to take '
    'pictures';
const String microPhonePermissionHeading = 'Microphone';
const String microPhonePermissionSubHeading =
    'Allow microphone permission to access '
    'audio';
const String allowPermissions = 'ALLOW PERMISSIONS';
const String permissionsErrorMsg = 'Please grant permissions before proceeding';
const String emailString = 'Email Id';
const String userNameString = 'Username';
const String enterEmail = 'Enter Email';
const String enterUserName = 'Enter Username';
const String passwordString = 'Password';
const String enterPassword = 'Password';
const String loginString = 'Login';
const String getOtpString = 'Get OTP';
const String verifyOtpString = 'Verify OTP';
const String enterOtpString = 'Enter OTP';
const String otpErrorMsg = 'Please enter valid OTP';
const String mobileNoString = 'Mobile Number';
const String notReceivedOtp = "Didn't receive OTP";
const String resendOtpString = 'Resend';
const String enterMobileNumber = 'Enter Mobile Number';
const String forgotPasswordString = 'Forgot Password?';
const String emptyEmailErrorMsg = 'Email cannot be empty';
const String emptyUsernameErrorMsg = 'Username cannot be empty';
const String invalidEmailErrorMsg = 'Invalid email';
const String emptyPasswordErrorMsg = 'Password cannot be empty';
const String emptyMobileNumberErrorMsg = 'Mobile number cannot be empty';
const String invalidMobileNumberErrorMsg = 'Enter valid Mobile number';
const String currentlyUnderDevMsg = 'Currently under development!';
const String toManyLoginAttempts =
    'Too many login attempts. Please wait for 15 minutes and try again';
const String noNetworkAvailability = 'Please check your network connection, no internet available';
const String farmerAccountDeletedSuccessfully = 'Your account has been deleted Successfully';
const String genericErrorMsg = 'Something went wrong, please try later';
const String otpExpiredMsg = 'OTP is expired';
const String invalidOtpErrMsg = 'OTP is Invalid';
const String responseErrorMsg = 'These farms are already updated';
const String underDevelopment = 'Currently under development';
const String plotRejectedMsg = 'This plot has been rejected';
const String plotNotVerifiedMsg = 'This plot has not been verified yet';
const String notVerifiedMsg = 'Not Verified';
const String farmerRegApprovedMsg = 'Farmer Registration was Approved';
const String farmerRegRejectedMsg = 'Farmer Registration was Rejected';
const String fieldRegApprovedMsg = 'Atleast one field was Approved';
const String fieldRegRejectedMsg = 'All the fields were Rejected';
const String cropApprovedMsg = 'Atleast one crop was Approved';
const String cropRejectedMsg = 'All the Crops were Rejected';
const String markerValidation = 'Please drop atleast two markers on Farm boundary';
const String aims = 'AIMS';
const String ownerInformation = 'Farmer Registration';
const String familyInformation = 'Family Information';
const String bankInformation = 'Bank Information';
const String fieldInformation = 'Add Field Information';
const String cropInformation = 'Add Crop Information';
const String cropMonitering = 'Crop Monitoring';
const String app = 'App';
const String selectRole = 'Please select your role';
const String farmer = 'Farmer';
const String serveyor = 'Surveyor';
const String department = 'Department';
const String otherVendor = 'Other Vendor';
const String loginto = 'Login';
const String account = 'Account';
const String fieldId = 'Field ID';
const String gisArea = 'GIS Area';
const String notSurveyed = 'Not Surveyed';
const String surveyed = 'Surveyed';
const String accepted = 'Accepted';
const String rejected = 'Rejected';
const String reSubmitted = 'Resubmitted';
const String cropInfo = 'Crop Info';
const String ownerInfo = 'Owner Info';
const String otherInfo = 'Other Info';
String cropName = 'Crop Name';
String farmType = 'Farming Type';
const String verifyCrop = 'Verify Crop Sown';
const String cropGroup = 'Crop Group';
const String enter = 'Enter';
const String addDetails = 'Add Details';
const String ownerRegistration = "Farmer's Registration";
const String bankDetails = 'Bank A/C Details';
const String cropDetails = 'Plot details';
const String plotDetails = 'Crop details';
const String location = 'Location';
const String plotListString = 'Plot List';
const String plots = 'Plots';
const String home = 'Home';
const String market = 'Market';
const String report = 'Report';
const String helpDesk = 'Helpdesk';
const String welcomeFarmer =  "Hi, Welcome Farmer";
const String back =  "Back";
const String addCrop =  "Add Crop";
const String viewCropInfo =  "View Crop";
const String addCropPhoto =  "Add Crop Photo";
const String fieldHistory =  "Field History";
const String viewScheme =  "View Scheme";
const String reportCropLoss =  "Report Crop Loss";
const String cropVariety = 'Crop Variety';
const String enterCropName = 'Enter Correct Crop Name';
const String cropVarietyError = 'Crop Variety cannot be empty';
const String cropNameError = 'Crop Name cannot be empty';
const String sowingDate = 'Sowing Date';
const String sowingDateErrorMessage = 'Sowing Date cannot be empty';
const String tentativeCropDurationErrorMsg =
    'Tentative Crop Duration cannot be empty';
const String tentativeCropDuration = 'Tentative Crop Duration';
const String expectedHarvestedDateErrorMsg =
    'Expected Harvested Date cannot be empty';
const String expectedHarvestedDate = 'Expected Harvested Date';
const String cropPhoto = 'Crop Photo';
const String capturePhotoErrorMsg = 'Please capture picture';
const String capturePhoto = 'Capture Photo';
const String submit = 'Submit';
const String continueText = 'Continue';
const String register = 'Register';
const String addBankDetails = 'Add Bank Details';
const String area = 'Area(As per registration, Acre)';
const String areaErrorMsg = 'Area cannot be empty';
const String waterSourceErrorMsg = 'Water Source cannot be empty';
const String cultivateBy = 'Cultivated By';
const String select = 'Select';
const String irrigationSource = 'Irrigation Source';
const String landType = 'Land Type';
const String expectedYield = 'Yield (kg/ha)';
const String expectedYieldErrorMsg = 'Yield cannot be empty';
const String locationErrorMsg = 'Please select location';
const String selectLocation = 'Select Location';
const String ownerName = 'Name';
const String ownerMobNo = 'Owner Mobile Number';
const String surveyNo = 'Survey Number';
const String ownerFatherName = 'Owner Father Name';
const String ownerNameErrMsg = 'Owner Name cannot be empty';
const String ownerMobNoErrMsg = 'Owner Mobile Number cannot be empty';
const String ownerFatherNameErrMsg = 'Owner Father Name cannot be empty';
const String surveyNoErrMsg = 'Survey Number cannot be empty';
const String subSurveyNoErrMsg = 'Sub Survey Number cannot be empty';
const String emailIdErrMsg = 'Email ID cannot be empty';
const String aadharNoErrMsg = 'Aadhar Number cannot be empty';
const String panNoErrMsg = 'PAN Number cannot be empty';
const String genderErrMsg = 'Gender cannot be empty';
const String dobErrMsg = 'DOB cannot be empty';
const String educationQualificationErrMsg = 'Education Qualification cannot be empty';
const String pincodeErrMsg = 'Pincode cannot be empty';
const String streetErrMsg = 'Street cannot be empty';
const String houseNoErrMsg = 'House No cannot be empty';
const String wardErrMsg = 'Ward Number cannot be empty';
const String villageErrMsg = 'Village Name cannot be empty';
const String bankErrMsg = 'Bank Name cannot be empty';
const String branchNameErrMsg = 'Branch Name cannot be empty';
const String accountNoErrMsg = 'Account Number cannot be empty';
const String repeatAccNoErrMsg = 'Repeat account Number cannot be empty';
const String repeatAccNoNotSameErrMsg = 'Repeat Account No and Account No must be same';
const String ifscLengthErrMsg = 'IFSC code must be 11-16 digits';
const String accountNoLengthErrMsg = 'Account number must be 11-16 digits';
const String ifscErrMsg = 'IFSC code cannot be empty';
const String noPointSurveyDataMsg = 'No Points have been Surveyed yet';

const String clickFromCamera = 'Click from Camera';
const String clickFromGallery = 'Click from Gallery';

const String cancel = 'Cancel';
const String confirm = 'CONFIRM';
const String clear = 'CLEAR';
const String mergeText = 'MERGE';
const String splitText = 'SPLIT';
const String insertText = 'INSERT';
const String deleteText = 'DELETE';
const String loaderText = 'Loading';
const String updateFarmsMsg = 'Updating farms';
const String lineStringText = 'LineString';
const String search = 'Search';
const String registeredSuccessfulMsg = 'Farmer registered Successfully!';
const String fieldDataDeletionSuccessfulMsg = 'Field Data deleted Successfully!';
const String mergeSuccessfulMsg = 'Merged Successfully!';
const String splitSuccessfulMsg = 'Splitted Successfully!';
const String submitSuccessfulMsg = 'Submitted Successfully!';
const String surveyedFarmDeletionMsg = 'Surveyed farm cannot be deleted';
const String farmerRegisteredCheck = 'Please Register the Farmer';
const String plotInfoCheck = 'Please submit the Plot data';
const String selectSurveyType = 'Please Select Survey Type';
const String selectAnOption= 'Please select an option';
const String tFarmerName = 'Tenant Farmer Name';
const String tFarmerNameErrorMessage = 'Tenant Farmer Name cannot be empty';
const String tMobileNo = 'Tenant Mobile Number';
const String tMobileNoErrorMsg = 'Tenant Mobile Number cannot be empty';
const String allocatedArea = 'Allocated Area(Acre)';
const String allocatedAreaErrorMsg = 'Allocated Area cannot be empty';
const String tenancyStartDate = 'Tenancy Start Date';
const String tenancyStartDateErrorMsg = 'Tenancy Start Date cannot be empty';
const String tenancyEndDate = 'Tenancy End Date';
const String tenancyEndDateErrorMsg = 'Tenancy End Date cannot be empty';
const String enterValidMobileNo = 'Please Enter Valid Mobile Number';
const String enterValidEmailId = 'Please Enter Valid Email Address';
const String enterValidAadharNo = 'Please Enter Valid Aadhar Number';
const String enterValidPanNo = 'Please Enter Valid PAN Number';
const String enterValidPincode= 'Please Enter Valid Pincode';
const String imageCaptureErrorMessage = 'Did not capture image';
const String maxImageCaptureMessage =
    'Cannot capture any more photographs, limit reached';
const String captureImage = 'Please Capture Images';
const String districtErrorMsg = 'District Name cannot be empty';
const String blockErrorMsg = 'Block Name cannot be empty';
const String panchayatErrorMsg = 'Panchayat Name cannot be empty';
const String splitToolTipMsg = 'Please drop markers across boundaries';
const String locationPermissionMsg = 'Please grant Location permission to use this feature';

const String mapType = 'Map Type';


enum CropSownRadioOptions {village, field}
enum NameSortRadioOptions {ascending, descending}
enum CropNameVerifyRadioOptions {agree, disagree}

//Role Names
const String aoRoleName = "Agricultural Officer";
const String ngrok = "https://d5d8-196-12-47-4.ngrok-free.app/session/create_session";   ///apwrims
// const String ngrok = "https://ded2-196-12-47-4.ngrok-free.app/session/create_session";   ///gowater

const int ownerCultivator = 1;
const int ownerCultivatorCumTenant = 2;
const int ownerNotCultivating = 3;
const int landlessTenant = 4;
const int wetland = 1;
const int dryLand = 2;