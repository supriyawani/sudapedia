import 'package:http/http.dart' as http;

import '../Common/Constant.dart';
import '../Model/LoginResponse.dart';

class Login_repo {
  Future<LoginResponse> getLogin(String EmployeeID) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(Constant.url + Constant.url_login));

    request.fields.addAll({
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'employee_id': EmployeeID
    });
    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    print(response);
    print(res);
    return responseFromJson(res);
  }
}
