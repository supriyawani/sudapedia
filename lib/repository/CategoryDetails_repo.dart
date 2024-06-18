import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Model/CategoryDetailsResponse.dart';

class CategoryDetails_repo {
  Future<List<PdfArr?>> getPDFList(String userToken, String id) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST', Uri.parse(Constant.url + Constant.url_categorydetails));

    request.bodyFields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
      'category_id': id,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);

    List<PdfArr?> result;

    /*  if (jsonData is Map<String, dynamic>) {
      // If the response is a map and contains a key 'data'
      if (jsonData.containsKey('pdf_arr')) {
        final List t = jsonData['pdf_arr'];
        final List<PdfArr> userList =
            t.map((item) => PdfArr.fromJson(item)).toList();
        result = userList.toSet().toList();
      } else {
        result = List.empty();
      }
    } else if (jsonData is List) {
      final List t = jsonData;
      final List<PdfArr> userList =
          t.map((item) => PdfArr.fromJson(item)).toList();
      result = userList.toSet().toList();
    } else {
      result = List.empty();
    }*/
    if (jsonData.toString().contains("Successfull !!")) {
      // If the response is a map and contains a key 'data'
      if (jsonData.containsKey('pdf_arr')) {
        final dynamic pdfData = jsonData['pdf_arr'];
        if (pdfData is String && pdfData == "Coming Soon !!") {
          displayToast(jsonData['pdf_arr'].toString());
          result = List.empty();
        } else {
          final List t = jsonData['pdf_arr'];
          final List<PdfArr> userList =
              t.map((item) => PdfArr.fromJson(item)).toList();
          result = userList.toSet().toList();
        }
      } else {
        result = List.empty();
      }
    } else if (jsonData is List) {
      final List t = jsonData;
      final List<PdfArr> userList =
          t.map((item) => PdfArr.fromJson(item)).toList();
      result = userList.toSet().toList();
    } else {
      result = List.empty();
    }

    return result;
  }

  Future<String?> getCategoryName(String userToken, String id) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    // print(Constant.url + Constant.url_categorydetails);
    var request = http.MultipartRequest(
        'POST', Uri.parse(Constant.url + Constant.url_categorydetails));
    var bodyfields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
      'category_id': id,
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
    /* if (jsonData != null && jsonData['msg'] == "Inavlid User Token Key") {
      throw Exception('Invalid User Token Key');
    } else*/
    if (jsonData.toString().contains("Successfull !!")) {
      data = jsonData['CategoryName'];
      print("data:" + data);
      return data;
    } else {
      throw Exception('Invalid User Token Key');
    }
  }

  Future<List<SubcategoriesArr?>> getSubCategory(
      String userToken, String id) async {
    print("inside subcategory");
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.MultipartRequest(
        'POST', Uri.parse(Constant.url + Constant.url_categorydetails));
    var bodyfields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
      'category_id': id,
    };
    // print("bodyfields" + bodyfields.toString());

    request.fields.addAll(bodyfields);

    print("body:" + bodyfields.toString());
    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);
    print("res:" + res);
    List<SubcategoriesArr?> result;

    if (jsonData != null && jsonData['msg'] == "Inavlid User Token Key") {
      throw Exception('Invalid User Token Key');
    } else if (jsonData is Map<String, dynamic>) {
      // If the response is a map and contains a key 'data'
      if (jsonData.containsKey('Subcategories_arr')) {
        final List t = jsonData['Subcategories_arr'];
        final List<SubcategoriesArr> userList =
            t.map((item) => SubcategoriesArr.fromJson(item)).toList();
        result = userList.toSet().toList();
      } else {
        result = List.empty();
      }
    } else if (jsonData is List) {
      final List t = jsonData;
      final List<SubcategoriesArr> userList =
          t.map((item) => SubcategoriesArr.fromJson(item)).toList();
      result = userList.toSet().toList();
    } else {
      result = List.empty();
    }

    return result;
  }

  void displayToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      // msg: "PDFs are coming soon!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
