import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Model/SubCategoryButtonResponse.dart';

class SubCategoryButtonDetails_repo {
  Future<List<ColorCode_arr?>> getSubcategorybuttonDetailsList(String userToken,
      String id, String subCategoryid, String colorId, String groupID) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request('POST',
        Uri.parse(Constant.url + Constant.url_subcategoryButtonsDetails));

    request.bodyFields = {
      Constant.apiKey: Constant.apiKey_value,
      Constant.UserToken: userToken,
      'category_id': id,
      'SubCategory_id': subCategoryid,
      'color_id': colorId,
      Constant.groupID: groupID
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    print("res:" + res);
    var jsonData = json.decode(res);

    List<ColorCode_arr?> result;

    if (jsonData is Map<String, dynamic> &&
        jsonData.containsKey('ColorDetails_arr')) {
      final dynamic pdfData = jsonData['ColorDetails_arr'];
      if (pdfData is String && pdfData == "Coming Soon !!") {
        Constant.displayToast(jsonData['ColorDetails_arr'].toString());
        result = List.empty();
      } else {
        final List t = jsonData['ColorDetails_arr'];
        final List<ColorCode_arr> userList =
            t.map((item) => ColorCode_arr.fromJson(item)).toList();
        result = userList.toSet().toList();
      }
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

  Future<String?> getcolorTitle(String userToken, String id,
      String subCategoryid, String colorId, String groupID) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    print(Constant.url + Constant.url_subcategoryButtons);
    var request = http.MultipartRequest('POST',
        Uri.parse(Constant.url + Constant.url_subcategoryButtonsDetails));
    var bodyfields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
      'category_id': id,
      'SubCategory_id': subCategoryid,
      'color_id': colorId,
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
      data = jsonData['Color Title'];
      print("data:" + data);
    }
    return data;
  }
}
