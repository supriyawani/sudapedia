import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Pigments.dart';
import 'package:sudapedia/repository/Otp_repo.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _employeeIDController;
  final _loadingController = StreamController<bool>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late String _Otp;
  String _employeeID = ''; // Initialize with an empty string
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    _employeeIDController = TextEditingController();
    _loadEmployeeID();
  }

  Future<void> _loadEmployeeID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? employeeID = prefs.getString('employeeID');
    setState(() {
      _employeeID = employeeID ?? '';
      _employeeIDController.text = _employeeID; // Handle null case
    });
    print("_employeeID: " + _employeeID);
  }

  @override
  void dispose() {
    _employeeIDController.dispose();
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
          DatabaseHelper dbHelper = DatabaseHelper();

          // await dbHelper.insertToken(response.userToken.toString());
          bool success =
              await dbHelper.insertToken1(response.userToken.toString());

          if (success) {
            print("User token inserted successfully!");
          } else {
            print("Failed to insert user token.");
          }
          //  await dbHelper.insertEmployeeID(_employeeIDController.text.toString());
          print("User token inserted successfully!");
          Navigator.push(
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
                          maxLength: 10,
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
                        /* onTap: () async {
                          String userToken = "FTGHI2W8XS";

                          DatabaseHelper dbHelper = DatabaseHelper();
                          await dbHelper.insertToken(userToken);
                          //  await DatabaseHelper().insertToken(userToken);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Pigments()));
                        },*/
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