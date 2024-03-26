class DepartmentUserPermissionsResponse {
  bool? result;
  int? statusCode;
  String? statusCodeDescription;
  dynamic message;
  ApiResponseData? response;

  DepartmentUserPermissionsResponse({
    this.result,
    this.statusCode,
    this.statusCodeDescription,
    this.message,
    this.response,
  });

  factory DepartmentUserPermissionsResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentUserPermissionsResponse(
      result: json['result'],
      statusCode: json['statusCode'],
      statusCodeDescription: json['statusCodeDescription'],
      message: json['message'],
      response: json['response'] != null ? ApiResponseData.fromJson(json['response']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'statusCode': statusCode,
      'statusCodeDescription': statusCodeDescription,
      'message': message,
      'response': response?.toJson(),
    };
  }
}

class ApiResponseData {
  Meta? meta;
  Permissions? permissions;

  ApiResponseData({
    this.meta,
    this.permissions,
  });

  factory ApiResponseData.fromJson(Map<String, dynamic> json) {
    return ApiResponseData(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      permissions: json['permissions'] != null ? Permissions.fromJson(json['permissions']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta?.toJson(),
      'permissions': permissions?.toJson(),
    };
  }
}

class Meta {
  String? userId;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  UserDetails? userDetails;
  String? createdTs;
  String? updatedTs;
  String? lastLoginTs;
  bool? status;
  String? title;
  String? customerId;
  String? customerName;
  dynamic customAttributes;
  bool? is_mobile_app;

  Meta({
    this.userId,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNo,
    this.userDetails,
    this.createdTs,
    this.updatedTs,
    this.lastLoginTs,
    this.status,
    this.title,
    this.customerId,
    this.customerName,
    this.customAttributes,
    this.is_mobile_app,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      userId: json['userId'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      mobileNo: json['mobileNo'],
      userDetails: json['userDetailsJson'] != null ? UserDetails.fromJson(json['userDetailsJson']) : null,
      createdTs: json['createdTs'],
      updatedTs: json['updatedTs'],
      lastLoginTs: json['lastLoginTs'],
      status: json['status'],
      title: json['title'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      customAttributes: json['customAttributes'],
      is_mobile_app: true
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
      'userDetailsJson': userDetails?.toJson(),
      'createdTs': createdTs,
      'updatedTs': updatedTs,
      'lastLoginTs': lastLoginTs,
      'status': status,
      'title': title,
      'customerId': customerId,
      'customerName': customerName,
      'customAttributes': customAttributes,
      'is_mobile_app' : true
    };
  }
}

class UserDetails {
  Data? data;
  dynamic scope;

  UserDetails({
    this.data,
    this.scope,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      scope: json['scope'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'scope': scope,
    };
  }
}

class Data {
  String? locType;
  Location? location;

  Data({
    this.locType,
    this.location,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      locType: json['locType'],
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locType': locType,
      'location': location?.toJson(),
    };
  }
}

class Location {
  List<Country>? country;

  Location({
    this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'] != null ? List<Country>.from(json['country'].map((x) => Country.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country?.map((e) => e.toJson()).toList(),
    };
  }
}

class Country {
  String? countryName;
  String? countryUUID;
  List<State>? state;

  Country({
    this.countryName,
    this.countryUUID,
    this.state,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryName: json['countryName'],
      countryUUID: json['countryUUID'],
      state: json['state'] != null ? List<State>.from(json['state'].map((x) => State.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryName': countryName,
      'countryUUID': countryUUID,
      'state': state?.map((e) => e.toJson()).toList(),
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
      'district': district?.map((e) => e.toJson()).toList(),
    };
  }
}

class District {
  String? districtName;
  String? districtUUID;
  List<Block>? block;

  District({
    this.districtName,
    this.districtUUID,
    this.block,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtName: json['districtName'],
      districtUUID: json['districtUUID'],
      block: json['block'] != null ? List<Block>.from(json['block'].map((x) => Block.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'districtName': districtName,
      'districtUUID': districtUUID,
      'block': block?.map((e) => e.toJson()).toList(),
    };
  }
}

class Block {
  String? blockName;
  String? blockUUID;
  List<Panchayat>? panchayat;

  Block({
    this.blockName,
    this.blockUUID,
    this.panchayat,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      blockName: json['blockName'],
      blockUUID: json['blockUUID'],
      panchayat: json['panchayat'] != null ? List<Panchayat>.from(json['panchayat'].map((x) => Panchayat.fromJson(x))) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blockName': blockName,
      'blockUUID': blockUUID,
      'panchayat': panchayat?.map((e) => e.toJson()).toList(),
    };
  }
}

class Panchayat {
  String? panchayatName;
  String? panchayatUUID;

  Panchayat({
    this.panchayatName,
    this.panchayatUUID,
  });

  factory Panchayat.fromJson(Map<String, dynamic> json) {
    return Panchayat(
      panchayatName: json['panchayatName'],
      panchayatUUID: json['panchayatUUID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'panchayatName': panchayatName,
      'panchayatUUID': panchayatUUID,
    };
  }
}

class Permissions {
  KRISHIDSS? kRISHIDSS;

  Permissions({this.kRISHIDSS});

  Permissions.fromJson(Map<String, dynamic> json) {
    kRISHIDSS = json['KRISHIDSS'] != null
        ? new KRISHIDSS.fromJson(json['KRISHIDSS'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.kRISHIDSS != null) {
      data['KRISHIDSS'] = this.kRISHIDSS!.toJson();
    }
    return data;
  }
}

class KRISHIDSS {
  String? applicationId;
  String? applicationName;
  String? roleId;
  String? roleName;
  UserRoleScope? userRoleScope;
  Resource? resources;

  KRISHIDSS(
      {this.applicationId,
        this.applicationName,
        this.roleId,
        this.roleName,
        this.userRoleScope,
        this.resources});

  KRISHIDSS.fromJson(Map<String, dynamic> json) {
    applicationId = json['applicationId'];
    applicationName = json['applicationName'];
    roleId = json['roleId'];
    roleName = json['roleName'];
    userRoleScope = json['userRoleScope'] != null
        ? new UserRoleScope.fromJson(json['userRoleScope'])
        : null;
    resources = json['resources'] != null
        ? new Resource.fromJson(json['resources'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['applicationId'] = this.applicationId;
    data['applicationName'] = this.applicationName;
    data['roleId'] = this.roleId;
    data['roleName'] = this.roleName;
    if (this.userRoleScope != null) {
      data['userRoleScope'] = this.userRoleScope!.toJson();
    }
    if (this.resources != null) {
      data['resources'] = this.resources!.toJson();
    }
    return data;
  }
}

class UserRoleScope {
  dynamic data;
  List<dynamic>? scope;

  UserRoleScope({
    this.data,
    this.scope,
  });

  factory UserRoleScope.fromJson(Map<String, dynamic> json) {
    return UserRoleScope(
      data: json['data'],
      scope: json['scope'] != null ? List<dynamic>.from(json['scope']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'scope': scope,
    };
  }
}

class Resource {
  String? resourceId;
  String? resourceName;
  List<String>? actions;
  dynamic actionsInfo;
  dynamic resourceTypeName;

  Resource({
    this.resourceId,
    this.resourceName,
    this.actions,
    this.actionsInfo,
    this.resourceTypeName,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      resourceId: json['resourceId'],
      resourceName: json['resourceName'],
      actions: json['actions'] != null ? List<String>.from(json['actions']) : null,
      actionsInfo: json['actionsInfo'],
      resourceTypeName: json['resourceTypeName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceId': resourceId,
      'resourceName': resourceName,
      'actions': actions,
      'actionsInfo': actionsInfo,
      'resourceTypeName': resourceTypeName,
    };
  }
}
