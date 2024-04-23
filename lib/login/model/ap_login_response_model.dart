import 'package:gka/utils/common_constants.dart' as constants;

class ApLoginResult {
  String? id;
  Result? result;

  ApLoginResult({
    this.id,
    this.result,
  });

  factory ApLoginResult.fromJson(Map<String, dynamic> json) {
    return ApLoginResult(
      id: json['id'],
      result: json['result'] != null ? Result.fromJson(json['result']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'result': result?.toJson(),
    };
  }
}

class Result {
  bool? success;
  int? status;
  dynamic metadata;
  Content? content;
  String? message;

  Result({
    this.success,
    this.status,
    this.metadata,
    this.content,
    this.message,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      success: json['success'],
      status: json['status'],
      metadata: json['metadata'],
      content: json['content'] != null ? Content.fromJson(json['content']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status': status,
      'metadata': metadata,
      'content': content?.toJson(),
      'message': message,
    };
  }
}

class Content {
  String? project_uuid;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  dynamic roles;
  dynamic permissions;
  UserDetailsJson? userDetailsJson;
  dynamic approver;
  dynamic passwordHash;
  dynamic createdTs;
  dynamic updatedTs;
  dynamic deleted;
  dynamic token;
  dynamic status;
  bool? userInfoEncrypted;
  String? userId;

  Content({
    this.project_uuid,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNo,
    this.roles,
    this.permissions,
    this.userDetailsJson,
    this.approver,
    this.passwordHash,
    this.createdTs,
    this.updatedTs,
    this.deleted,
    this.token,
    this.status,
    this.userInfoEncrypted,
    this.userId,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      project_uuid: constants.apwrimsUUID.toString(),
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      roles: json['roles'],
      permissions: json['permissions'],
      userDetailsJson: json['userDetailsJson'] != null ? UserDetailsJson.fromJson(json['userDetailsJson']) : null,
      approver: json['approver'],
      passwordHash: json['passwordHash'],
      createdTs: json['createdTs'],
      updatedTs: json['updatedTs'],
      deleted: json['deleted'],
      token: json['token'],
      status: json['status'],
      userInfoEncrypted: json['userInfoEncrypted'],
      userId: json['userId'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobileNo': mobileNo,
      'roles': roles,
      'permissions': permissions,
      'userDetailsJson': userDetailsJson?.toJson(),
      'approver': approver,
      'passwordHash': passwordHash,
      'createdTs': createdTs,
      'updatedTs': updatedTs,
      'deleted': deleted,
      'token': token,
      'status': status,
      'userInfoEncrypted': userInfoEncrypted,
      'userId': userId,
      'project_uuid': constants.apwrimsUUID.toString(),
    };
  }
}

class UserDetailsJson {
  Data? data;

  UserDetailsJson({
    this.data,
  });

  factory UserDetailsJson.fromJson(Map<String, dynamic> json) {
    return UserDetailsJson(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}

class Data {
  Location? location;
  String? locType;

  Data({
    this.location,
    this.locType,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      locType: json['locType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location?.toJson(),
      'locType': locType,
    };
  }
}

class Location {
  List<State>? state;

  Location({
    this.state,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      state: json['state'] != null ? List<State>.from(json['state'].map((x) => State.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state?.map((x) => x.toJson()).toList(),
    };
  }
}

class State {
  String? stateName;
  String? stateUUID;
  List<District>? district;

  State({
    this.stateName,
    this.stateUUID,
    this.district,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      stateName: json['stateName'],
      stateUUID: json['stateUUID'],
      district: json['district'] != null ? List<District>.from(json['district'].map((x) => District.fromJson(x))) : null,
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

class District {
  String? districtName;
  String? districtUUID;
  List<Mandal>? mandal;

  District({
    this.districtName,
    this.districtUUID,
    this.mandal,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtName: json['districtName'],
      districtUUID: json['districtUUID'],
      mandal: json['mandal'] != null ? List<Mandal>.from(json['mandal'].map((x) => Mandal.fromJson(x))) : null,
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

class Mandal {
  String? mandalName;
  String? mndalUUID;

  Mandal({
    this.mandalName,
    this.mndalUUID,
  });

  factory Mandal.fromJson(Map<String, dynamic> json) {
    return Mandal(
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