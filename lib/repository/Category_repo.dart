import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Model/CategoriesResponse.dart';

class Category_repo {
  Stream<List<CategoriesResponse>> getCategoryStream(String userToken) async* {
    var request = http.MultipartRequest(
        'POST', Uri.parse(Constant.url + Constant.url_categories));
    print("userToken:" + userToken);
    request.fields.addAll({
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
    });

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    print("res: $res");

    var jsonData = json.decode(res);
    print(
        "jsonData: ${json.encode(jsonData)}"); // Properly stringify JSON for printing

    if (jsonData != null && jsonData['categories_arr'] != null) {
      final List<dynamic> categoriesList = jsonData['categories_arr'];
      yield categoriesList
          .map((item) => CategoriesResponse.fromJson(item))
          .toList();
    } else {
      yield [];
    }
  }
  //return responseFromJson(res);
}
