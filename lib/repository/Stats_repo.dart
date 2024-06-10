import 'package:http/http.dart' as http;

class Stats_repo {
  final String apiUrl =
      'https://sudapedia.sudarshan.com/Admin/web-api/stats.php';

  Future<void> fetchCategoryData(
      String userToken, String id, String pdf_id, String employeeId) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {
      'apiKey': '8c961641025d48b7b89d475054d656da',
      'UserToken': userToken,
      'employee_id': employeeId,
      'pdf_id': pdf_id,
      //'category_id': '12',
    };

    var response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: body);
    print("response:" + body.toString());
    if (response.body.toString().contains("Successfully !!")) {
      // Successful response
      print('API Response: ${response.body}');
    } else {
      // Handle API error
      print('API Error: ${response.statusCode}');
    }
  }
}
