import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:sudapedia/SendOTP.dart';

import '../Database/DatabaseHelper.dart';

class Constant {
  static String url = "https://sudapedia.sudarshan.com/Admin/web-api/";
  //static String url = "https://beta-sudapedia.sudarshan.com/Admin/web-api/";
  static String url_pdf_path = "https://sudapedia.sudarshan.com/Admin/";
  static String url_login = "Login.php";
  static String url_logout = "logout.php";
  static String url_otp = "Otp.php";
  static String url_categories = "Categories.php";
  //static String api_key = "8c961641025d48b7b89d475054d656da";
  static String url_categorydetails = "CategoriesDetails.php";
  static String url_pdf = "PDFs.php";
  static String url_subcategoryButtons = "SubCategoryButtons.php";
  static String url_subcategoryButtonsDetails = "SubCategoryButtonsDetails.php";
  static String url_comparison = "Comparisons.php";

  static String url_notification = "notification.php";

  static String groupID = "group_id";
  static String apiKey_value = "8c961641025d48b7b89d475054d656da";
  static String apiKey = "apiKey";
  static String UserToken = "UserToken";

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static Future<void> logCategoryItemTap({
    required String categoryId,
    required String categoryName,
  }) async {
    String? emplyeeid = (await DatabaseHelper().getEmployeeID());
    try {
      await _analytics.logEvent(
        name: 'category',
        parameters: {
          'employee_id': emplyeeid,
          'category_id': categoryId,
          'category_name': categoryName,
        },
      );
      print('Event logged: category_item_tap');
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  static Future<void> logpdf({
    required String pdfname,
  }) async {
    String? emplyeeid = (await DatabaseHelper().getEmployeeID());
    try {
      await _analytics.logEvent(
        name: 'category',
        parameters: {
          'employee_id': emplyeeid,
          'pdf_name': pdfname,
        },
      );
      print('Event logged: category_item_tap');
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  late final Mixpanel mixpanel;
  Future<void> initMixpanel(String screenName) async {
    /* mixpanel.track("Screen Viewed", properties: {
      "Screen Name": screenName,
    }); */
    //mixpanel = await Mixpanel.init("62ddf5b857e7c7599006c1200e6d2680");
    mixpanel = await Mixpanel.init("74e0d8e0c7c5a746e5fbca830902f411");
    //mixpanel = await Mixpanel.init("ce929324ba3b21726809dc3bb81bde27");
    final dbHelper = DatabaseHelper();
    final employeeID = await dbHelper.getEmployeeID();
    print("employeeId:" + employeeID.toString());
    print(screenName);
    mixpanel.identify(employeeID.toString());
    mixpanel.track(screenName);
    //mixpanel.track(screenName);
  }

  static Color getColor(String code) {
    switch (code) {
      case 'A':
        return Color(0xFFFFB2B2);
      case 'B':
        return Color(0xFFFFDFBA);
      case 'C':
        return Color(0xFFD6FFF0);
      case 'D':
        return Color(0xFFE4FFC1);
      case 'E':
        return Color(0xFFBEDCFF);
      case 'F':
        return Color(0xFFD9FCFF);
      case 'G':
        return Color(0xFFFFCDEB);
      case 'H':
        return Color(0xFFE1BAFF);
      case 'I':
        return Color(0xFFFFB2B2);
      case 'J':
        return Color(0xFFFF9BBF);
      case 'K':
        return Color(0xFFFF9BBF);

      default:
        return Color(0xFFFFDFBA); // fallback image
    }
  }

  static void displayToast(String msg) {
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

  LinearGradient getGradient(String code) {
    List<Color> colors = [];
    List<double> stops = [];
    switch (code) {
      case 'A':
        colors = [Color(0xFFFFC6C6), Color(0xFFFF8888)];
        stops = [0.0, 1.0];
        break;
      case 'B':
        colors = [Color(0xFFFFD4A3), Color(0xFFFFBB6D)];
        stops = [0.0, 1.0];
        break;
      case 'C':
        colors = [Color(0xFFBFFFE8), Color(0xFF38FFB7)];
        stops = [0.0, 1.0];
        break;
      case 'D':
        colors = [Color(0xFFD8FFA6), Color(0xFFACFF42)];
        stops = [0.60, 1.0];
        break;
      case 'E':
        colors = [Color(0xFF92C4FF), Color(0xFF50A0FF)];
        stops = [0.0, 1.0];
        break;
      case 'F':
        colors = [Color(0xFFD2FCFF), Color(0xFF71F7FF)];
        stops = [0.45, 1.0];
        break;
      case 'G':
        colors = [Color(0xFF), Color(0xFF)];
        stops = [0.0, 0.1];
        break;
      case 'H':
        colors = [Color(0xFFDBADFF), Color(0xFFC478FF)];
        stops = [0.0, 1.0];
        break;
      case 'I':
        colors = [Color(0xFFFF9B9B), Color(0xFFFF6464)];
        stops = [0.26, 1.0];
        break;
      case 'J':
        colors = [Color(0xFFFFA4C5), Color(0xFFFF5A95)];
        stops = [0.0, 1.0];
        break;
      // Add more cases for other color codes as needed
      default:
        colors = [Colors.black, Colors.black];
    }

    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static String invalidToken = "Invalid User Token Key";
  static void navigatetoSendotp(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SendOTP()),
      (route) => false,
    );
  }
}

class Utils {
  static void handleInvalidToken(BuildContext context, dynamic error) {
    if (error.toString().contains('Invalid User Token Key')) {
      // Use Future.microtask to ensure the navigation is triggered
      Future.microtask(() => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SendOTP()),
          ));
    }
  }
}
