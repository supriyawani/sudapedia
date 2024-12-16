import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Model/PDFSubCategoryResponse.dart';

class PDFSubCategory_repo {
  Future<List<PdfArrforSubCategory?>> getPDFList(
      String userToken,
      String id,
      String subCategoryid,
      String colorId,
      String colorcodeid,
      String groupID) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.MultipartRequest(
        'POST', Uri.parse(Constant.url + Constant.url_pdf));

    var bodyFields = {
      Constant.apiKey: Constant.apiKey_value,
      Constant.UserToken: userToken,
      'category_id': id,
      'SubCategory_id': subCategoryid,
      'color_id': colorId,
      'color_code_id': colorcodeid,
      Constant.groupID: groupID
    };
    print("bodyFields:" + bodyFields.toString());
    //request.headers.addAll(headers);
    request.fields.addAll(bodyFields);
    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    print("res:" + res);
    var jsonData = json.decode(res);

    List<PdfArrforSubCategory?> result;

    if (jsonData.toString().contains("Successfull !!")) {
      // If the response is a map and contains a key 'data'
      if (jsonData.containsKey('pdf_arr')) {
        final dynamic pdfData = jsonData['pdf_arr'];
        if (pdfData is String && pdfData == "Coming Soon !!") {
          displayToast(jsonData['pdf_arr'].toString());
          result = List.empty();
        } else {
          final List t = jsonData['pdf_arr'];
          final List<PdfArrforSubCategory> userList =
              t.map((item) => PdfArrforSubCategory.fromJson(item)).toList();
          result = userList.toSet().toList();
        }
      } else {
        result = List.empty();
      }
    } else if (jsonData is List) {
      final List t = jsonData;
      final List<PdfArrforSubCategory> userList =
          t.map((item) => PdfArrforSubCategory.fromJson(item)).toList();
      result = userList.toSet().toList();
    } else {
      result = List.empty();
    }
    print("result from:" + result.toString());
    return result;
  }

  Future<String?> getColorDetailsTitle(
      String userToken,
      String id,
      String subCategoryid,
      String colorId,
      String colorcodeid,
      String groupID) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    print(Constant.url + Constant.url_categorydetails);
    var request = http.MultipartRequest(
        'POST', Uri.parse(Constant.url + Constant.url_pdf));
    var bodyfields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
      'category_id': id,
      'SubCategory_id': subCategoryid,
      'color_id': colorId,
      'color_code_id': colorcodeid,
      Constant.groupID: groupID
    };
    print("bodyfields:" + bodyfields.toString());

    request.fields.addAll(bodyfields);

    //print(Constant.API_URL + 'iOSClubNextMeetingId.php');
    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);
    var data = "";
    print(json.decode(res));
    if (jsonData != null) {
      data = jsonData['Color Details Title'];
      print("data:" + data);
    }
    return data;
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
