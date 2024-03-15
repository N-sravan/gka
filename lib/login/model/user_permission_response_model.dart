class UserPermissionsResponse {
  bool? result;
  int? statusCode;
  String? statusCodeDescription;
  String? message;
  Response? response;

  UserPermissionsResponse(
      {this.result,
        this.statusCode,
        this.statusCodeDescription,
        this.message,
        this.response});

  UserPermissionsResponse.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    statusCode = json['statusCode'];
    statusCodeDescription = json['statusCodeDescription'];
    message = json['message'];
    response = json['response'] != null
        ? new Response.fromJson(json['response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['result'] = this.result;
    data['statusCode'] = this.statusCode;
    data['statusCodeDescription'] = this.statusCodeDescription;
    data['message'] = this.message;
    if (this.response != null) {
      data['response'] = this.response!.toJson();
    }
    return data;
  }
}

class Response {
  Meta? meta;
  Permissions? permissions;

  Response({this.meta});

  Response.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? new Meta.fromJson(json['meta']) : null;
    permissions = json['permissions'] != null ? Permissions.fromJson(json['permissions']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.meta != null) {
      data['meta'] = this.meta!.toJson();
    }
    return data;
  }
}

class Meta {
  String? userId;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNo;
  UserDetailsJson? userDetailsJson;
  int? createdTs;
  int? updatedTs;
  String? lastLoginTs;
  bool? status;
  String? title;
  String? customerId;
  String? customerName;
  String? customAttributes;

  Meta(
      {this.userId,
        this.username,
        this.firstName,
        this.lastName,
        this.email,
        this.mobileNo,
        this.userDetailsJson,
        this.createdTs,
        this.updatedTs,
        this.lastLoginTs,
        this.status,
        this.title,
        this.customerId,
        this.customerName,
        this.customAttributes});

  Meta.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    username = json['username'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    mobileNo = json['mobileNo'];
    userDetailsJson = json['userDetailsJson'] != null
        ? new UserDetailsJson.fromJson(json['userDetailsJson'])
        : null;
    createdTs = json['createdTs'];
    updatedTs = json['updatedTs'];
    lastLoginTs = json['lastLoginTs'];
    status = json['status'];
    title = json['title'];
    customerId = json['customerId'];
    customerName = json['customerName'];
    customAttributes = json['customAttributes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['username'] = this.username;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['email'] = this.email;
    data['mobileNo'] = this.mobileNo;
    if (this.userDetailsJson != null) {
      data['userDetailsJson'] = this.userDetailsJson!.toJson();
    }
    data['createdTs'] = this.createdTs;
    data['updatedTs'] = this.updatedTs;
    data['lastLoginTs'] = this.lastLoginTs;
    data['status'] = this.status;
    data['title'] = this.title;
    data['customerId'] = this.customerId;
    data['customerName'] = this.customerName;
    data['customAttributes'] = this.customAttributes;
    return data;
  }
}

class UserDetailsJson {
  Data? data;
  Null? scope;

  UserDetailsJson({this.data, this.scope});

  UserDetailsJson.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    scope = json['scope'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['scope'] = this.scope;
    return data;
  }
}

class Data {
  Location? location;

  Data({this.location});

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
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
        state!.add(new State.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.state != null) {
      data['state'] = this.state!.map((v) => v.toJson()).toList();
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
        district!.add(new District.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stateName'] = this.stateName;
    data['stateUUID'] = this.stateUUID;
    if (this.district != null) {
      data['district'] = this.district!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class District {
  String? districtName;
  String? districtUUID;
  List<Block>? block;

  District({this.districtName, this.districtUUID, this.block});

  District.fromJson(Map<String, dynamic> json) {
    districtName = json['districtName'];
    districtUUID = json['districtUUID'];
    if (json['block'] != null) {
      block = <Block>[];
      json['block'].forEach((v) {
        block!.add(new Block.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['districtName'] = this.districtName;
    data['districtUUID'] = this.districtUUID;
    if (this.block != null) {
      data['block'] = this.block!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Block {
  String? blockName;
  String? blockUUID;
  List<Village>? village;

  Block({this.blockName, this.blockUUID, this.village});

  Block.fromJson(Map<String, dynamic> json) {
    blockName = json['blockName'];
    blockUUID = json['blockUUID'];
    if (json['village'] != null) {
      village = <Village>[];
      json['village'].forEach((v) {
        village!.add(new Village.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['blockName'] = this.blockName;
    data['blockUUID'] = this.blockUUID;
    if (this.village != null) {
      data['village'] = this.village!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Village {
  String? villageName;
  String? villageUUID;

  Village({this.villageName, this.villageUUID});

  Village.fromJson(Map<String, dynamic> json) {
    villageName = json['villageName'];
    villageUUID = json['villageUUID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['villageName'] = this.villageName;
    data['villageUUID'] = this.villageUUID;
    return data;
  }
}

class Permissions {
  KRISHIDSS? krishidss;

  Permissions({this.krishidss});

  Permissions.fromJson(Map<String, dynamic> json) {
    krishidss = json['KRISHIDSS'] != null ? KRISHIDSS.fromJson(json['KRISHIDSS']) : null;
  }
}

class KRISHIDSS {
  String? applicationId;
  String? applicationName;
  String? roleId;
  String? roleName;
  UserRoleScope? userRoleScope;
  Map<String, Resource>? resources;

  KRISHIDSS({
    this.applicationId,
    this.applicationName,
    this.roleId,
    this.roleName,
    this.userRoleScope,
    this.resources,
  });

  KRISHIDSS.fromJson(Map<String, dynamic> json) {
    applicationId = json['applicationId'];
    applicationName = json['applicationName'];
    roleId = json['roleId'];
    roleName = json['roleName'];
    userRoleScope = json['userRoleScope'] != null ? UserRoleScope.fromJson(json['userRoleScope']) : null;
    resources = {};
    if (json['resources'] != null) {
      json['resources'].forEach((key, value) {
        resources![key] = Resource.fromJson(value);
      });
    }
  }
}

class UserRoleScope {
  dynamic? data;
  List<dynamic>? scope;

  UserRoleScope({this.data, this.scope});

  UserRoleScope.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    scope = json['scope'] != null ? List<dynamic>.from(json['scope']) : [];
  }
}

class Resource {
  String? resourceId;
  String? resourceName;
  List<String>? actions;
  dynamic? actionsInfo;
  String? resourceTypeName;

  Resource({
    this.resourceId,
    this.resourceName,
    this.actions,
    this.actionsInfo,
    this.resourceTypeName,
  });

  Resource.fromJson(Map<String, dynamic> json) {
    resourceId = json['resourceId'];
    resourceName = json['resourceName'];
    actions = json['actions'] != null ? List<String>.from(json['actions']) : [];
    actionsInfo = json['actionsInfo'];
    resourceTypeName = json['resourceTypeName'];
  }
}