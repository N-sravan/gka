// import '../../forms/model/submitted_farmer_data_response_model.dart';
//
// class VerifyOtpResponse {
//   final bool result;
//   final int statusCode;
//   final String statusCodeDescription;
//   final String message;
//   ResponseData? response;
//
//   VerifyOtpResponse({
//     required this.result,
//     required this.statusCode,
//     required this.statusCodeDescription,
//     required this.message,
//     required this.response,
//   });
//
//   factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
//     return VerifyOtpResponse(
//       result: json['result'] ?? false,
//       statusCode: json['statusCode'] ?? 0,
//       statusCodeDescription: json['statusCodeDescription'] ?? '',
//       message: json['message'] ?? '',
//       response: json['response'] != null ? ResponseData.fromJson(json['response']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'result': result,
//       'statusCode': statusCode,
//       'statusCodeDescription': statusCodeDescription,
//       'message': message,
//       'response': response,
//     };
//   }
// }
