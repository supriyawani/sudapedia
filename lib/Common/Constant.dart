import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sudapedia/SendOTP.dart';

class Constant {
  //static String url = "https://sudapedia.sudarshan.com/Admin/web-api/";
  static String url = "https://beta-sudapedia.sudarshan.com/Admin/web-api/";
  static String url_pdf_path = "https://sudapedia.sudarshan.com/Admin/";
  static String url_login = "Login.php";
  static String url_logout = "logout.php";
  static String url_otp = "Otp.php";
  static String url_categories = "Categories.php";
  static String api_key = "8c961641025d48b7b89d475054d656da";
  static String url_categorydetails = "CategoriesDetails.php";
  static String url_pdf = "PDFs.php";
  static String url_subcategoryButtons = "SubCategoryButtons.php";
  static String url_subcategoryButtonsDetails = "SubCategoryButtonsDetails.php";
  static String url_comparison = "Comparisons.php";

  static String url_notification = "notification.php";

  static String groupID = "group_id";
  static String apiKey = "8c961641025d48b7b89d475054d656da";

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
