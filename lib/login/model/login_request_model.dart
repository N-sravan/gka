class LoginRequestParams {
  String username;
  String password;

  LoginRequestParams(this.username, this.password);

  LoginRequestParams.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        password = json['password'];

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}
