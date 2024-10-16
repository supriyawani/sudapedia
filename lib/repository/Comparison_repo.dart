import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Model/ComparisonResponse.dart';

class Comparison_repo {
  //Future<ComparisonResponse> fetchCategoryData() async {
  //final String apiUrl = 'https://sudapedia.sudarshan.com/Admin/web-api/Comparisons.php';
  final String apiUrl = Constant.url + Constant.url_comparison;

  Future<ComparisonResponse> fetchCategoryData(
      String userToken, String id, String groupID) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {
      'apiKey': '8c961641025d48b7b89d475054d656da',
      'UserToken': userToken,
      'category_id': id,
      Constant.groupID: groupID
      //'category_id': '12',
    };

    var response =
        await http.post(Uri.parse(apiUrl), headers: headers, body: body);
    print("response:" + response.body);
    if (response.body.contains("Successfull !!")) {
      var jsonResponse = json.decode(response.body);
      return ComparisonResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load category data');
    }
  }

  Future<String?> getCategoryName(
      String userToken, String id, String groupID) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    // print(Constant.url + Constant.url_categorydetails);
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    var bodyfields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
      'category_id': id,
      Constant.groupID: groupID
    };
    // print("bodyfields" + bodyfields.toString());

    request.fields.addAll(bodyfields);
    request.headers.addAll(headers);

    //print(Constant.API_URL + 'iOSClubNextMeetingId.php');
    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);
    var data = "";
    print(json.decode(res));
    if (jsonData != null) {
      data = jsonData['CategoryName'];
      return data;
    } else {
      throw Exception('Invalid User Token Key');
    }
  }
}
