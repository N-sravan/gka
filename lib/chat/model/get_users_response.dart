class UserResponseModel {
  final int? statusCode;
  final Map<String, User>? users;

  UserResponseModel({
    this.statusCode,
    this.users,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    var usersJson = json['response'] as Map<String, dynamic>;
    Map<String, User> users = usersJson.map((key, value) =>
        MapEntry(key, User.fromJson(value as Map<String, dynamic>)));

    return UserResponseModel(
      statusCode: json['statusCode'],
      users: users,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'response': users?.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class User {
  final String? userId;
  final String? name;
  final String? phone;
  final String? address;
  final String? tokenStatus;
  final String? userStatus;

  User({
    this.userId,
    this.name,
    this.phone,
    this.address,
    this.tokenStatus,
    this.userStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      tokenStatus: json['token_status'],
      userStatus: json['user_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'token_status': tokenStatus,
      'user_status': userStatus,
    };
  }
}
