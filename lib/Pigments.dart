import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/NewHomeScreen.dart';
import 'package:sudapedia/SendOTP.dart';
import 'package:sudapedia/SessionTimeoutManager.dart';

class Pigments extends StatefulWidget {
  @override
  _PigmentsState createState() => _PigmentsState();
}

class _PigmentsState extends State<Pigments> {
  final _formKey = GlobalKey<FormState>();
  String? userToken, employeeId;
  var isLoading = false;
  Timer? _logoutTimer;
  bool _isMounted = false;
  Timer? _countdownTimer;
  int _remainingTime = 2;

  // String? Token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_startLogoutTimer();
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isMounted = false;
    _logoutTimer?.cancel();
    super.dispose();
  }

  void _startLogoutTimer() async {
    /*const logoutDuration = Duration(minutes: 30);
    if (!(await SessionManager.isUserLoggedIn())) {
      return;
    }*/
    getToken();
    print("userToken:" + userToken.toString());
    print("employeeID:" + employeeId.toString());
/*
    _logoutTimer = Timer(logoutDuration,
        _logout(employeeId.toString(), userToken!) as void Function());*/
    // SessionTimeoutManager.startLogoutTimer(context);
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => SessionTimeoutManager.resetLogoutTimer(context),
        child: WillPopScope(onWillPop: () async {
          SessionTimeoutManager.resetLogoutTimer(context);
          return true;
        }, child: Sizer(builder: (context, orientation, deviceType) {
          return Scaffold(
              key: _scaffoldKey,
              body: Stack(children: <Widget>[
                Container(
                  padding: EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  //margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/background_image.png",
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 100.sp),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                                top: 220.sp, left: 20.sp, right: 20.sp),

                            // margin: EdgeInsets.symmetric(horizontal: 20.sp),
                            child: SvgPicture.asset(
                              "assets/pigments.svg",
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewHomeScreen(),
                              ),
                            );
                          },
                        ),
                        GestureDetector(
                          child: Container(
                            // margin: EdgeInsets.symmetric(horizontal: 20.sp),
                            margin: EdgeInsets.only(
                                bottom: 15.sp, left: 20.sp, right: 20.sp),
                            child: SvgPicture.asset(
                              "assets/logout.svg",
                            ),
                          ),
                          onTap: () async {
                            getToken();
                            print("userToken:" + userToken.toString());
                            print("employeeID:" + employeeId.toString());
                            _logout(employeeId.toString(), userToken!);
                          },
                        ),
                        GestureDetector(
                            child: Container(
                          alignment: Alignment.bottomCenter,
                          // margin: EdgeInsets.symmetric(horizontal: 20.sp,),
                          margin: EdgeInsets.only(top: 10.sp, bottom: 50.sp),
                          child: Image.asset(
                            "assets/sudarshan.png",
                          ),
                        )),
                      ],
                    ))
              ]));
        })));
  }

  Future<void> getToken() async {
    userToken = (await DatabaseHelper().getToken());
    employeeId = (await DatabaseHelper().getEmployeeID());
    //userToken = "1E5O3tCJuz03bib";
    print("Token:" + userToken!);
    // _categoriesStream = categoryRepo.getCategoryStream(userToken.toString());
  }

  Future<void> _logout(String employeeId, String token) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {
      'employee_id': employeeId,
      'UserToken': token,
      'apiKey': "8c961641025d48b7b89d475054d656da"
    };

    var response = await http.post(
        Uri.parse("https://sudapedia.sudarshan.com/Admin/web-api/logout.php"),
        headers: headers,
        body: body);
    print(response.body.toString());
    print(response.body);
    if (response.body.contains("Logout Successfully !!")) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['msg'] == 'Logout Successfully !!') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['msg'])),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SendOTP()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${jsonResponse['msg']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server')),
      );
    }
  }

  buildColumn() {
    return Container(child: Text(""));
  }
}
