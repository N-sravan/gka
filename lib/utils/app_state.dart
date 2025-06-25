class AppState {
  static AppState? _instance;

  AppState._();

  static AppState get instance => _instance ??= AppState._();

  String userName = "";
  late String role;
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
  Map<String, String> countryUUIDMapping = {};
  Map<String, String> stateUUIDMapping = {};
  Map<String, String> districtUUIDMapping = {};
  Map<String, String> blockUUIDMapping = {};
  Map<String, String> panchayatUUIDMapping = {};
  Map<String, String> villageUUIDMapping = {};
  Map<String, String> cropUUIDColorMapping = {};
  Map<String, String> cropUUIDNameMapping = {};
  Map<String, dynamic> plotUUIDAndStatusMap = {};
  Map<String, dynamic> csrfTokenUserDetails = {};
  Map<String, dynamic> userPermissions = {};
  Map<String, dynamic> userMetaDataMap = {};
  late String? hiveEncryptionKey;
  late String userData;
  late String fcmToken;
  String modelName = "chatgpt-3.5";
  String modelUUID = "43c31fae-3469-4c87-a73d-8648e9c78f3663";
  late String locUUID;
  late String locType;
  late String locName;
  late String userId;
  late String sessionId;
  late String language;
  late bool isEnglish;
  late String mode;
  late String transMode;
  late String sttMode;
  late String ttsMode;
  bool isListeningMode = false;
  
  // Chat display preferences
  bool showChainOfActions = true;
  bool showDetailedMode = true;
  bool autoSpeechEnabled = false;
  bool ttsChunkedMode = true; // true for chunked, false for full text
}
