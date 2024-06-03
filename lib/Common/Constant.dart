import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Constant {
  static String url = "https://sudapedia.sudarshan.com/Admin/web-api/";
  static String url_pdf_path = "https://sudapedia.sudarshan.com/Admin/";
  static String url_login = "Login.php";
  static String url_otp = "Otp.php";
  static String url_categories = "Categories.php";
  static String api_key = "8c961641025d48b7b89d475054d656da";
  static String url_categorydetails = "CategoriesDetails.php";
  static String url_pdf = "PDFs.php";
  static String url_subcategoryButtons = "SubCategoryButtons.php";
  static String url_subcategoryButtonsDetails = "SubCategoryButtonsDetails.php";

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
}
