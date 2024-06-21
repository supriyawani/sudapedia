import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/repository/Login_repo.dart';

import 'Login.dart';

class SendOTP extends StatefulWidget {
  @override
  _SendOTPState createState() => _SendOTPState();
}

class _SendOTPState extends State<SendOTP> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _employeeIDController = TextEditingController();
  final _loadingController = StreamController<bool>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void dispose() {
    _employeeIDController.dispose();
    _loadingController.close();
    super.dispose();
  }

  Future<void> _saveEmployeeID(String employeeID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('employeeID', employeeID);
  }

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      _loadingController.add(true);

      var apiProvider = Login_repo();
      print("_employeeIDController.text:" + _employeeIDController.text);
      var response = await apiProvider.getLogin(_employeeIDController.text);

      _loadingController.add(false);

      if (response != null) {
        try {
          if (response.msg.toString().contains("OTP Sent Successfully !!")) {
            //  await DatabaseHelper().insertEmployeeID(_employeeIDController.text);
            await _saveEmployeeID(_employeeIDController.text);
            Constant.displayToast(
                "You will receive the OTP on registered email id.");
            checkEmpId(_employeeIDController.text, response.oTP.toString());

            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Login()));
          } else {
            SnackBar(
                content: Text('Invalid response format. Please try again.'));
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Invalid response format. Please try again.')));
        }
      } else {
        // Handle null response, show a Snackbar or a Dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send OTP. Please try again.')),
        );
      }
    }
  }

  Future<void> checkEmpId(String _employee, String OTP) async {
    if (_employee == "888999") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('OTP', OTP);
      print("OTP:" + OTP);
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
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 15.sp, right: 15.sp),
                    child: TextFormField(
                      controller: _employeeIDController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      decoration: InputDecoration(
                        hintText: "EmployeeID",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 25.0),
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 4.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 4.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 4.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 4.0),
                        ),
                      ),
                      onSaved: (value) {
                        // _email = value!.trim();
                      },
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'EmployeeID is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _loadingController.stream,
                  builder: (context, snapshot) {
                    bool isLoading = snapshot.data ?? false;
                    return GestureDetector(
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
                                      "Send OTP",
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
                        onTap: isLoading ? null : _sendOTP);
                    /* onTap: () async {
                          // await DatabaseHelper().insertEmployeeID(_employeeIDController.text);
                          await _saveEmployeeID(_employeeIDController.text);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        });*/
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
