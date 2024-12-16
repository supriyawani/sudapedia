import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Common/Constant.dart';
import '../Model/OtpResponse.dart';

class Otp_repo {
  Future<OtpResponse?> getLogin(String employeeID, String otp) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request =
        http.Request('POST', Uri.parse(Constant.url + Constant.url_otp));
    request.bodyFields = {
      //'apiKey': "8c961641025d48b7b89d475054d656da",
      Constant.apiKey: Constant.apiKey_value,
      'employee_id': employeeID,
      'OTP': otp
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);
    print(jsonData);
    OtpResponse? result;
    if (jsonData['msg'] == "Login Successfully !!") {
      result = OtpResponse.fromJson(jsonData);
    } else {
      result = null;
    }
    return result;
  }
}
