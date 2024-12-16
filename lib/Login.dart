import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Pigments.dart';
import 'package:sudapedia/repository/Otp_repo.dart';

import 'Common/Constant.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _employeeIDController;
  late TextEditingController _OTPController;
  final _loadingController = StreamController<bool>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late String _Otp;
  String _employeeID = ''; // Initialize with an empty string

  var isLoading = false;
  //late SessionManager _sessionTimeoutManager;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  @override
  void initState() {
    super.initState();
    // _sessionTimeoutManager = SessionManager();
    _employeeIDController = TextEditingController();
    _OTPController = TextEditingController();
    _loadEmployeeID();
  }

  Future<void> _loadEmployeeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeID = prefs.getString('employeeID');
    String? OTP = prefs.getString('OTP');
    print("OTP:" + OTP.toString());
    setState(() {
      _employeeID = employeeID ?? '';
      _employeeIDController.text = _employeeID; // Handle null case
      if (_employeeID.toString() == "888999") {
        _OTPController.text = OTP ?? "";
        _Otp = OTP ?? '';
      }
    });
    print("_employeeID: " + _employeeID);
    print("_Otp: " + _Otp);
  }

  @override
  void dispose() {
    _employeeIDController.dispose();
    _OTPController.dispose();
    _loadingController.close();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _loadingController.add(true);
      setState(() {
        isLoading = true;
      });

      var apiProvider = Otp_repo();
      var response = await apiProvider.getLogin(_employeeID, _Otp);

      _loadingController.add(false);
      setState(() {
        isLoading = false;
      });

      if (response != null) {
        if (response.msg.toString().contains("Login Successfully !!")) {
          print("response" + response.toString());
          DatabaseHelper dbHelper = DatabaseHelper();

          // await dbHelper.insertToken(response.userToken.toString());
          //    bool success = await dbHelper.insertToken1(response.userToken.toString());
          bool success =
              await dbHelper.insertToken1(response.userToken.toString());

          await dbHelper.insertEmployeeID(_employeeID);
          String GroupID = response.result!.group_id.toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(Constant.groupID, GroupID);

          if (success) {
            print("User token inserted successfully!");
            // await dbHelper.insertGroupID(response.result!.group_id.toString());
          } else {
            print("Failed to insert user token.");
          }
          //  await dbHelper.insertEmployeeID(_employeeIDController.text.toString());
          print("User token inserted successfully!");
          //_sessionTimeoutManager.startSession(context);
          _saveLoginInfo();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Pigments()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg.toString())),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP.')),
        );
      }
    }
  }

  Future<void> _savenotificationCount(String notificationCount) async {
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.setString('notificationcount', notificationCount);
    // await DatabaseHelper().insertNotificationCount(notificationCount as int);
    int count = int.parse(notificationCount); // Convert String to int
    await DatabaseHelper().insertNotificationCount(count);
  }

  void _saveLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    // Other login information storage
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background_image.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(20.sp),
                  child: SvgPicture.asset(
                    "assets/welcome.svg",
                    height: 4.h,
                    width: 10.w,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: 15.sp, right: 15.sp, bottom: 10.sp),
                        child: TextFormField(
                          controller: _employeeIDController,
                          //  initialValue: _employeeID.toString(),
                          key: Key("_employeeID"),
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          decoration: InputDecoration(
                            hintText: "EmployeeID",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 25.0),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 4.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 4.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 4.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'EmployeeID is required';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _employeeID = value!.trim();
                          },
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: 15.sp, right: 15.sp, bottom: 10.sp),
                        child: TextFormField(
                          controller: _OTPController,
                          key: Key("_Otp"),
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          decoration: InputDecoration(
                            hintText: "OTP",
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 25.0),
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 4.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 4.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 4.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'OTP is required';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _Otp = value!.trim();
                          },
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                              left: 15.sp, right: 15.sp, top: 15.sp),
                          child: Material(
                            elevation: 5.0,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(8.sp),
                              width: double.infinity,
                              child: isLoading
                                  ? CircularProgressIndicator() // Show loading indicator if API call is in progress
                                  : Text(
                                      "Login",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp),
                                    ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                              ),
                            ),
                          ),
                        ),
                        onTap: isLoading ? null : _login,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
