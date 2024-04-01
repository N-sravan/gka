class UserDetailsJsonForAp {
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  List<dynamic>? roles;
  List<dynamic>? permissions;
  UserDetailsJson? userDetailsJson;
  dynamic? approver;
  dynamic? passwordHash;
  dynamic? createdTs;
  dynamic? updatedTs;
  dynamic? deleted;
  dynamic? token;
  dynamic? status;
  bool? userInfoEncrypted;
  String? userId;

  UserDetailsJsonForAp({
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

  UserDetailsJsonForAp.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    mobileNo = json['mobileNo'];
    roles = json['roles'];
    permissions = json['permissions'];
    userDetailsJson = json['userDetailsJson'] != null
        ? UserDetailsJson.fromJson(json['userDetailsJson'])
        : null;
    approver = json['approver'];
    passwordHash = json['passwordHash'];
    createdTs = json['createdTs'];
    updatedTs = json['updatedTs'];
    deleted = json['deleted'];
    token = json['token'];
    status = json['status'];
    userInfoEncrypted = json['userInfoEncrypted'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['email'] = email;
    data['mobileNo'] = mobileNo;
    data['roles'] = roles;
    data['permissions'] = permissions;
    if (userDetailsJson != null) {
      data['userDetailsJson'] = userDetailsJson!.toJson();
    }
    data['approver'] = approver;
    data['passwordHash'] = passwordHash;
    data['createdTs'] = createdTs;
    data['updatedTs'] = updatedTs;
    data['deleted'] = deleted;
    data['token'] = token;
    data['status'] = status;
    data['userInfoEncrypted'] = userInfoEncrypted;
    data['userId'] = userId;
    return data;
  }
}

class UserDetailsJson {
  Data? data;

  UserDetailsJson({this.data});

  UserDetailsJson.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Location? location;
  String? locType;

  Data({this.location, this.locType});

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? Location.fromJson(json['location']) : null;
    locType = json['locType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['locType'] = locType;
    return data;
  }
}

class Location {
  List<State>? state;

  Location({this.state});

  Location.fromJson(Map<String, dynamic> json) {
    if (json['state'] != null) {
      state = <State>[];
      json['state'].forEach((v) {
        state!.add(State.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (state != null) {
      data['state'] = state!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class State {
  String? stateName;
  String? stateUUID;
  List<District>? district;

  State({this.stateName, this.stateUUID, this.district});

  State.fromJson(Map<String, dynamic> json) {
    stateName = json['stateName'];
    stateUUID = json['stateUUID'];
    if (json['district'] != null) {
      district = <District>[];
      json['district'].forEach((v) {
        district!.add(District.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stateName'] = stateName;
    data['stateUUID'] = stateUUID;
    if (district != null) {
      data['district'] = district!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class District {
  String? districtName;
  String? districtUUID;
  List<Mandal>? mandal;

  District({this.districtName, this.districtUUID, this.mandal});

  District.fromJson(Map<String, dynamic> json) {
    districtName = json['districtName'];
    districtUUID = json['districtUUID'];
    if (json['mandal'] != null) {
      mandal = <Mandal>[];
      json['mandal'].forEach((v) {
        mandal!.add(Mandal.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['districtName'] = districtName;
    data['districtUUID'] = districtUUID;
    if (mandal != null) {
      data['mandal'] = mandal!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Mandal {
  String? mandalName;
  String? mndalUUID;

  Mandal({this.mandalName, this.mndalUUID});

  Mandal.fromJson(Map<String, dynamic> json) {
    mandalName = json['mandalName'];
    mndalUUID = json['mndalUUID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mandalName'] = mandalName;
    data['mndalUUID'] = mndalUUID;
    return data;
  }
}
