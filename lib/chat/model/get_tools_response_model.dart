class ToolInventoryResponseModel {
  final bool? result;
  final int? statusCode;
  final String? statusCodeDescription;
  final String? message;
  final List<RainfallData>? response;

  ToolInventoryResponseModel({
    this.result,
    this.statusCode,
    this.statusCodeDescription,
    this.message,
    this.response,
  });

  factory ToolInventoryResponseModel.fromJson(Map<String, dynamic> json) {
    return ToolInventoryResponseModel(
      result: json['result'],
      statusCode: json['statusCode'],
      statusCodeDescription: json['statusCodeDescription'],
      message: json['message'],
      response: json['response'] != null ? List<RainfallData>.from(json['response'].map((x) => RainfallData.fromJson(x))) : null,
    );
  }
}

class RainfallData {
  final String? name;
  final String? tuuid;
  final String? desc;
  final String? srcType;
  final String? src;
  final String? projName;
  final String? projUuid;
  final String? userUuid;
  final DataParams? dataParams;
  final FilterParams? filterParams;

  RainfallData({
    this.name,
    this.tuuid,
    this.desc,
    this.srcType,
    this.src,
    this.projName,
    this.projUuid,
    this.userUuid,
    this.dataParams,
    this.filterParams,
  });

  factory RainfallData.fromJson(Map<String, dynamic> json) {
    return RainfallData(
      name: json['name'],
      tuuid: json['tuuid'],
      desc: json['desc'],
      srcType: json['src_type'],
      src: json['src'],
      projName: json['proj_name'],
      projUuid: json['proj_uuid'],
      userUuid: json['user_uuid'],
      dataParams: json['data_params'] != null ? DataParams.fromJson(json['data_params']) : null,
      filterParams: json['filter_params'] != null ? FilterParams.fromJson(json['filter_params']) : null,
    );
  }
}

class DataParams {
  final DataParam? state;
  final DataParam? district;

  DataParams({
    this.state,
    this.district,
  });

  factory DataParams.fromJson(Map<String, dynamic> json) {
    return DataParams(
      state: json['state'] != null ? DataParam.fromJson(json['state']) : null,
      district: json['district'] != null ? DataParam.fromJson(json['district']) : null,
    );
  }
}

class DataParam {
  final String? type;
  final bool? isMandatory;
  final String? defaultValue;

  DataParam({
    this.type,
    this.isMandatory,
    this.defaultValue,
  });

  factory DataParam.fromJson(Map<String, dynamic> json) {
    return DataParam(
      type: json['type'],
      isMandatory: json['is_mandatory'] == "true",
      defaultValue: json['default_value'],
    );
  }
}

class FilterParams {
  final FilterParam? varName;

  FilterParams({
    this.varName,
  });

  factory FilterParams.fromJson(Map<String, dynamic> json) {
    return FilterParams(
      varName: json['var_name'] != null ? FilterParam.fromJson(json['var_name']) : null,
    );
  }
}

class FilterParam {
  final String? type;

  FilterParam({
    this.type,
  });

  factory FilterParam.fromJson(Map<String, dynamic> json) {
    return FilterParam(
      type: json['type'],
    );
  }
}