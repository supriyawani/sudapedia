import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Model/SubCategoryButtonResponse.dart';

class SubCategoryButton_repo {
  Future<List<ColorCode_arr?>> getSubcategorybuttonList(
      String userToken, String id, String subCategoryid, String groupId) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST', Uri.parse(Constant.url + Constant.url_subcategoryButtons));

    request.bodyFields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
      'category_id': id.trim(),
      'SubCategory_id': subCategoryid.trim(),
      Constant.groupID: groupId
    };
    print("body:" + request.bodyFields.toString());
    request.headers.addAll(headers);
    print('Request URL: ${request.url}');
    print('Request Headers: ${request.headers}');
    print('Request Body: ${request.bodyFields}');
    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    print('Response status: ${response.statusCode}');
    print('Response body: $res');
    var jsonData = json.decode(res);
    List<ColorCode_arr?> result;
    // if (jsonData is Map<String, dynamic>) {
    // If the response is a map and contains a key 'data'
    //  if (jsonData.containsKey('ColorCode_arr')) {
    if (jsonData is Map<String, dynamic> &&
        jsonData.containsKey('ColorCode_arr')) {
      /*final List t = jsonData['ColorCode_arr'];
      final List<ColorCode_arr> userList =
          t.map((item) => ColorCode_arr.fromJson(item)).toList();
      result = userList.toSet().toList();*/
      final dynamic pdfData = jsonData['ColorCode_arr'];
      if (pdfData is String && pdfData == "Coming Soon !!") {
        Constant.displayToast(jsonData['ColorCode_arr'].toString());
        result = List.empty();
      } else {
        final List t = jsonData['ColorCode_arr'];
        final List<ColorCode_arr> userList =
            t.map((item) => ColorCode_arr.fromJson(item)).toList();
        result = userList.toSet().toList();
      }
      /*}else {
        result = List.empty();
      }*/
    } else if (jsonData is List) {
      final List t = jsonData;
      final List<ColorCode_arr> userList =
          t.map((item) => ColorCode_arr.fromJson(item)).toList();
      result = userList.toSet().toList();
    } else {
      result = List.empty();
    }

    return result;
  }

  Future<String?> getsubCategoryName(
      String userToken, String id, String subCategoryid, String groupID) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    print(Constant.url + Constant.url_subcategoryButtons);
    var request = http.MultipartRequest(
        'POST', Uri.parse(Constant.url + Constant.url_subcategoryButtons));
    var bodyfields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
      'category_id': id,
      'SubCategory_id': subCategoryid,
      Constant.groupID: groupID
    };
    print("bodyfields" + bodyfields.toString());

    request.fields.addAll(bodyfields);

    //print(Constant.API_URL + 'iOSClubNextMeetingId.php');
    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    print(res);
    var jsonData = json.decode(res);
    var data = "";
    print(json.decode(res));
    if (jsonData != null) {
      data = jsonData['SubCategoryName'];
      print("data:" + data);
    }
    return data;
  }
}
