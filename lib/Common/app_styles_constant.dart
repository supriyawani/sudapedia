import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppStylesConstant {
  static TextStyle regularFontStyle(DeviceType deviceType,
      {Color color = Colors.black}) {
    return TextStyle(
        fontSize: deviceType == DeviceType.tablet ? 12.sp : 10.sp,
        color: Colors.black);
  }

  static TextStyle textFieldCountErrorStyle(DeviceType deviceType) {
    return TextStyle(fontSize: deviceType == DeviceType.tablet ? 7.sp : 10.sp);
  }

  static TextStyle boldFontStyle(DeviceType deviceType,
      {Color color = Colors.black}) {
    return TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: deviceType == DeviceType.tablet ? 12.sp : 10.sp,
        color: Colors.black);
  }

  static EdgeInsets marginEdgeInsets(DeviceType deviceType) {
    double value = deviceType == DeviceType.tablet ? 15.sp : 10.sp;
    return EdgeInsets.only(left: value, right: value);
  }

  static EdgeInsets contentPadding(DeviceType deviceType) {
    return deviceType == DeviceType.tablet
        ? EdgeInsets.symmetric(vertical: 8.sp, horizontal: 10.sp)
        : EdgeInsets.symmetric(vertical: 15.sp, horizontal: 25.sp);
  }
}
