import 'dart:convert';

LoginResponse responseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String responseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  String? success;
  String? failure;
  String? msg;
  String? oTP;
  Result? result;

  LoginResponse({this.success, this.failure, this.msg, this.oTP, this.result});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    failure = json['Failure'];
    msg = json['msg'];
    oTP = json['OTP'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Success'] = this.success;
    data['Failure'] = this.failure;
    data['msg'] = this.msg;
    data['OTP'] = this.oTP;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class Result {
  String? id;
  String? name;
  String? accessLevel;
  String? email;
  String? employeeId;

  Result({this.id, this.name, this.accessLevel, this.email, this.employeeId});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    accessLevel = json['AccessLevel'];
    email = json['Email'];
    employeeId = json['employee_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Name'] = this.name;
    data['AccessLevel'] = this.accessLevel;
    data['Email'] = this.email;
    data['employee_id'] = this.employeeId;
    return data;
  }
}
