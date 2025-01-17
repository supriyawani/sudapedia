import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Model/NotificationResponse.dart';

import '../Database/DatabaseHelper.dart';

class Notification_repo {
  Future<List<NotificationArr?>> getNotification(String userToken) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST', Uri.parse(Constant.url + Constant.url_notification));

    request.bodyFields = {
      Constant.apiKey: Constant.apiKey_value,
      Constant.UserToken: userToken,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);

    List<NotificationArr?> result;
    if (jsonData != null && jsonData['msg'] == "Inavlid User Token Key") {
      throw Exception('Invalid User Token Key');
    } else if (jsonData.toString().contains("Successfull !!")) {
      // If the response is a map and contains a key 'data'
      if (jsonData.containsKey('notifications_arr')) {
        final dynamic pdfData = jsonData['notifications_arr'];
        final List t = jsonData['notifications_arr'];
        final List<NotificationArr> userList =
            t.map((item) => NotificationArr.fromJson(item)).toList();
        result = userList.toSet().toList();
        int count =
            int.parse(userList.length.toString()); // Convert String to int
        await DatabaseHelper().insertNotificationCount(count);
        print("count:" + count.toString());
      } else {
        result = List.empty();
      }
    } else if (jsonData is List) {
      final List t = jsonData;
      final List<NotificationArr> userList =
          t.map((item) => NotificationArr.fromJson(item)).toList();
      result = userList.toSet().toList();
    } else {
      result = List.empty();
    }

    return result;
  }

  Future<List<NotificationArr?>> getseachNotification(
      String userToken, String query) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST', Uri.parse(Constant.url + Constant.url_notification));

    request.bodyFields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': userToken,
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);

    List<NotificationArr> result = [];
    if (jsonData.toString().contains("Successfull !!")) {
      final List t = jsonData['notifications_arr'];
      final List<NotificationArr> userList =
          t.map((item) => NotificationArr.fromJson(item)).toList();

      if (query.isNotEmpty) {
        result = userList
            .where((element) => element.nottifications!
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      } else {
        result = userList;
      }

      print("Length " + result.length.toString());
    }
    return result;
    //return responseFromJson(res);
  }
}
