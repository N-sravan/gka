
import 'package:event_bus/event_bus.dart';

import '../login/model/department_user_permission_response.dart';

class AppState {
  static AppState? _instance;

  AppState._();

  static AppState get instance => _instance ??= AppState._();

  String userName = "";
  late String userAssignedRole;
  late String userEmail;
  late String userMobileNo;
  late String userUUID;
  late String token;
  late String refreshToken;
  late String csrfToken;
  late String userState;
  late String stateUUID;
  late String userDistrict;
  late String districtUUID;
  late String userBlock;
  late String blockUUID;
  late String userPanchayat;
  late String panchayatUUID;
  late String userVillage;
  late String villageUUID;
  late String surveyYear;
  late String surveySeason;
  late String tappedFarmUUID;
  late String tappedPointUUID;
  late String latitude;
  late String longitude;
  Map<String,String> countryUUIDMapping = {};
  Map<String,String> stateUUIDMapping = {};
  Map<String,String> districtUUIDMapping = {};
  Map<String,String> blockUUIDMapping = {};
  Map<String,String> panchayatUUIDMapping = {};
  Map<String,String> villageUUIDMapping = {};
  Map<String,String> cropUUIDColorMapping = {};
  Map<String,String> cropUUIDNameMapping = {};
  Map<String,dynamic> plotUUIDAndStatusMap = {};
  late String? hiveEncryptionKey;
  late bool? isFarmSurvey;
  late bool? isPlotForm;
  late String role;
  late String farmerUUID;
  late String tappedFieldUUID;
  late String userData;
  String triggeredWord = '';
  late String fcmToken;
  bool hasFarmerData=false;
  bool isVoiceUpdateEnabled=false;
  bool isVillageSelected = true;
  bool isOriyaSelected = false;
  bool isExternalLLM = false;
  late String modelName;
  late String modelUUID;
  late String locUUID;
  late String locType;
  late String locName;
  late String userId;

  //For Background Sync
  bool isSyncInProgress = false;
  EventBus eventBus = EventBus();
}
