import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Common/Constant.dart';
import '../Model/LoginResponse.dart';

class Login_repo {
  Future<LoginResponse> getLogin(String EmployeeID) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(Constant.url + Constant.url_login));

    request.fields.addAll({
      //  'apiKey': "8c961641025d48b7b89d475054d656da",
      Constant.apiKey: Constant.apiKey_value,
      'employee_id': EmployeeID
    });

    http.StreamedResponse response = await request.send();
    // Print response status code and headers for debugging
    print('Response status code: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    var res = await response.stream.bytesToString();
    print("response:" + response.toString());
    print("res:" + res);
    if (res.isEmpty) {
      throw Exception('Server returned an empty response');
    }
    return responseFromJson(res);
  }

  LoginResponse responseFromJson(String str) {
    final jsonData = json.decode(str);
    return LoginResponse.fromJson(jsonData);
  }
}
