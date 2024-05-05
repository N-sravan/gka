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
const String preferenceUserData = 'userData';
const String preferenceToken = 'token';
const String preferenceFcmToken = 'fcmToken';
const String preferencelocName = 'locName';
const String preferencelocUUID = 'locUUID';
const String preferencelocType = 'locType';
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
const String imageUploadUrl =
    'https://agriwise.vassarlabs.com/agribot/bucket/insert_file';
/*const String krishidsBaseUrl =
    'http://agriwise.vassarlabs.com/api';*/ //-

const String loginEndpoint =
    'https://gowater-staging.vassarlabs.com/um/api/getUserDetailsForChatbot/';
const String saveFcmTokenEndpoint = 'fcm_tokens/save_token';
const String deleteTokenEndpoint = 'fcm_tokens/delete_token';
const String getAvailabeModelsEndpoint = 'get_available_models';
const String getAvailabePromptsEndpoint = 'get_all_prompt_templates';
const String logoutEndpoint =
    'auth/realms/agriwiserealm/protocol/openid-connect/logout';
const String csrfEndPoint = 'um/generate-csrf-token';
const String userPermissionsEndPoint = 'um/user-permissions/';
const String getToolsEndpoint = 'tool_inventory/get_tools';
const String updatePromptTemplateEndpoint = 'update_prompt_template';
const String createPromptTemplateEndpoint = 'create_prompt_template';
const String createSessionEndpoint = 'session/create_session';

//UUIDs & keys
const String indiaUUID = 'd6b37905-d2d3-4275-9317-d9b6f47cd783';
const String odishaUUID = 'd19a5290-2e40-494a-83d2-98f4c845b1f1';
const String kaleswaramUUID = '927b67e9-a2aa-46e9-99bc-41cf8c502668';
const String apwrimsUUID = '6f86292b-dd9a-4987-bb8f-c3940263b349';

//check this before generating apk
const String projectId = '6f86292b-dd9a-4987-bb8f-c3940263b349';

// Paddings
const double largePadding = 32;
const double mediumPadding = 16;
const double smallPadding = 8;
const double xSmallPadding = 4;

// Dimensions
const double splashIconHeight = 150;
const double splashIconWidth = 120;
const double departmentIconTop = 134;
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
const Color containerColor = Color.fromRGBO(118, 118, 128, 0.12);
const Color labelColor = Color.fromRGBO(255, 255, 255, 1);
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
const Color darkBlue = Color.fromRGBO(6, 32, 64, 1);
const Color inputFieldColor = Color.fromRGBO(118, 118, 128, 0.12);
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

TextStyle gray24W500 = const TextStyle(
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 24.0,
    color: Color.fromRGBO(29, 31, 36, 1));

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
const String genericErrorMsg = 'Something went wrong, please try later';
const String currentlyUnderDevMsg = 'Currently under development!';
const String toManyLoginAttempts =
    'Too many login attempts. Please wait for 15 minutes and try again';
const String noNetworkAvailability =
    'Please check your network connection, no internet available';
const String loginto = 'Login';
const String userNameString = 'Username';
const String emptyUsernameErrorMsg = 'Username cannot be empty';
const String submit = 'Submit';
const String emptyPasswordErrorMsg = 'Password cannot be empty';
const String enterUserName = 'Enter Username';
const String passwordString = 'Password';
const String enterPassword = 'Password';
const String loginString = 'Login';

const String clickFromCamera = 'Click from Camera';
const String clickFromGallery = 'Click from Gallery';

const String cancel = 'Cancel';

enum CropSownRadioOptions { village, field }

enum NameSortRadioOptions { ascending, descending }

enum CropNameVerifyRadioOptions { agree, disagree }

const String genAiBaseUrl = "https://genai.vassarlabs.com/aquamind/";
const String ngrok = "https://bbe1-196-12-47-4.ngrok-free.app/";
