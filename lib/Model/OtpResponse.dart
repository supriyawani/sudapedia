import 'dart:convert';

OtpResponse responseFromJson(String str) =>
    OtpResponse.fromJson(json.decode(str));

String responseToJson(OtpResponse data) => json.encode(data.toJson());

class OtpResponse {
  String? success;
  String? failure;
  String? msg;
  String? userToken;
  String? notification_count;
  Result? result;

  OtpResponse(
      {this.success,
      this.failure,
      this.msg,
      this.userToken,
      this.notification_count,
      this.result});

  OtpResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    failure = json['Failure'];
    msg = json['msg'];
    userToken = json['UserToken'];
    notification_count = json['notification_count'];
    result =
        json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Success'] = this.success;
    data['Failure'] = this.failure;
    data['msg'] = this.msg;
    data['UserToken'] = this.userToken;
    data['notification_count'] = this.notification_count;
    if (this.result != null) {
      data['result'] = this.result!.toJson();
    }
    return data;
  }
}

class Result {
  String? id;
  String? email;
  String? password;
  String? name;
  String? contactNumber;
  String? accessLevel;
  String? displayStatus;
  String? lastAccessTime;
  String? employeeId;
  String? isLogin;
  String? otp;
  String? token;
  String? regTime;

  Result(
      {this.id,
      this.email,
      this.password,
      this.name,
      this.contactNumber,
      this.accessLevel,
      this.displayStatus,
      this.lastAccessTime,
      this.employeeId,
      this.isLogin,
      this.otp,
      this.token,
      this.regTime});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    email = json['Email'];
    password = json['Password'];
    name = json['Name'];
    contactNumber = json['ContactNumber'];
    accessLevel = json['AccessLevel'];
    displayStatus = json['DisplayStatus'];
    lastAccessTime = json['LastAccessTime'];
    employeeId = json['employee_id'];
    isLogin = json['is_login'];
    otp = json['otp'];
    token = json['token'];
    regTime = json['RegTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['Email'] = this.email;
    data['Password'] = this.password;
    data['Name'] = this.name;
    data['ContactNumber'] = this.contactNumber;
    data['AccessLevel'] = this.accessLevel;
    data['DisplayStatus'] = this.displayStatus;
    data['LastAccessTime'] = this.lastAccessTime;
    data['employee_id'] = this.employeeId;
    data['is_login'] = this.isLogin;
    data['otp'] = this.otp;
    data['token'] = this.token;
    data['RegTime'] = this.regTime;
    return data;
  }
}
