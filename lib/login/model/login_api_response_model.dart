import 'package:gka/utils/common_constants.dart' as constants;

class LoginResult {
  bool result;
  int statusCode;
  String statusCodeDescription;
  dynamic message;
  UserResponse response;

  LoginResult({
    required this.result,
    required this.statusCode,
    required this.statusCodeDescription,
    required this.message,
    required this.response,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      result: json['result'],
      statusCode: json['statusCode'],
      statusCodeDescription: json['statusCodeDescription'],
      message: json['message'],
      response: UserResponse.fromJson(json['response']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'statusCode': statusCode,
      'statusCodeDescription': statusCodeDescription,
      'message': message,
      'response': response.toJson(),
    };
  }
}

class UserResponse {
  String userId;
  String username;
  String firstName;
  String lastName;
  String email;
  String mobileNo;
  UserDetails userDetailsJson;
  int createdTs;
  int updatedTs;
  dynamic lastLoginTs;
  bool status;
  String title;
  String customerId;
  String customerName;
  dynamic customAttributes;
  String project_uuid;

  UserResponse({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobileNo,
    required this.userDetailsJson,
    required this.createdTs,
    required this.updatedTs,
    required this.lastLoginTs,
    required this.status,
    required this.title,
    required this.customerId,
    required this.customerName,
    required this.customAttributes,
    required this.project_uuid,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      userId: json['userId'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      userDetailsJson: UserDetails.fromJson(json['userDetailsJson']),
      createdTs: json['createdTs'],
      updatedTs: json['updatedTs'],
      lastLoginTs: json['lastLoginTs'],
      status: json['status'],
      title: json['title'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customAttributes: json['customAttributes'],
      project_uuid: constants.projectId.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNo': mobileNo,
      'userDetailsJson': userDetailsJson.toJson(),
      'createdTs': createdTs,
      'updatedTs': updatedTs,
      'lastLoginTs': lastLoginTs,
      'status': status,
      'title': title,
      'customerId': customerId,
      'customerName': customerName,
      'customAttributes': customAttributes,
      'project_uuid': project_uuid,
    };
  }
}

class UserDetails {
  UserDataDetails data;
  dynamic scope;

  UserDetails({
    required this.data,
    required this.scope,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      data: UserDataDetails.fromJson(json['data']),
      scope: json['scope'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'scope': scope,
    };
  }
}

class UserDataDetails {
  UserDataLocation location;
  String locType;

  UserDataDetails({
    required this.location,
    required this.locType,
  });

  factory UserDataDetails.fromJson(Map<String, dynamic> json) {
    return UserDataDetails(
      location: UserDataLocation.fromJson(json['location']),
      locType: json['locType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'locType': locType,
    };
  }
}

class UserDataLocation {
  List<UserDataState> state;

  UserDataLocation({
    required this.state,
  });

  factory UserDataLocation.fromJson(Map<String, dynamic> json) {
    var stateList = json['state'] as List;
    List<UserDataState> states =
        stateList.map((state) => UserDataState.fromJson(state)).toList();
    return UserDataLocation(state: states);
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state.map((state) => state.toJson()).toList(),
    };
  }
}

class UserDataState {
  String? stateName;
  String? stateUUID;
  List<UserDataDistrict>? district;

  UserDataState({
    required this.stateName,
    required this.stateUUID,
    this.district,
  });

  factory UserDataState.fromJson(Map<String, dynamic> json) {
    return UserDataState(
      stateName: json['stateName'],
      stateUUID: json['stateUUID'],
      district: json['district'] != null
          ? List<UserDataDistrict>.from(json['district'].map((x) => UserDataDistrict.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stateName': stateName,
      'stateUUID': stateUUID,
      'district': district?.map((x) => x.toJson()).toList(),
    };
  }
}

class UserDataDistrict {
  String districtName;
  String districtUUID;
  List<UserDataMandal>? mandal;

  UserDataDistrict({
    required this.districtName,
    required this.districtUUID,
    this.mandal,
  });

  factory UserDataDistrict.fromJson(Map<String, dynamic> json) {
    return UserDataDistrict(
      districtName: json['districtName'],
      districtUUID: json['districtUUID'],
      mandal: json['mandal'] != null
          ? List<UserDataMandal>.from(json['mandal'].map((x) => UserDataMandal.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'districtName': districtName,
      'districtUUID': districtUUID,
      'mandal': mandal?.map((x) => x.toJson()).toList(),
    };
  }
}

class UserDataMandal {
  String mandalName;
  String mndalUUID;

  UserDataMandal({
    required this.mandalName,
    required this.mndalUUID,
  });

  factory UserDataMandal.fromJson(Map<String, dynamic> json) {
    return UserDataMandal(
      mandalName: json['mandalName'],
      mndalUUID: json['mndalUUID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mandalName': mandalName,
      'mndalUUID': mndalUUID,
    };
  }
}
