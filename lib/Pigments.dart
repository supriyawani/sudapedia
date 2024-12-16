import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/NewHomeScreen.dart';
import 'package:sudapedia/SendOTP.dart';

class Pigments extends StatefulWidget {
  late final FirebaseAnalytics analytics;

  //Pigments({required this.analytics});
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
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  late final Mixpanel mixpanel;
  // String? Token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_startLogoutTimer();
    //logEvent('screen_view', {'screen_name': 'Pigments'});
    logEvent();
    setState(() {});
    Constant().initMixpanel("Pigments");
    // mixpanel.track("Pigments");
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
    return /*GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => SessionTimeoutManager.resetLogoutTimer(context),
        child: WillPopScope(onWillPop: () async {
          SessionTimeoutManager.resetLogoutTimer(context);
          return true;
        }, child: */
        Sizer(builder: (context, orientation, deviceType) {
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
                // margin: EdgeInsets.all(50.sp),
                margin: EdgeInsets.only(top: 50.sp, bottom: 50.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: 50.sp, left: 80.sp, right: 80.sp),
                      //   margin: EdgeInsets.symmetric(horizontal: 20.sp),
                      child: Image.asset(
                        "assets/Sudapedia_logo.png",
                      ),
                    ),
                    GestureDetector(
                      child: Container(
                        // padding: EdgeInsets.only(top: 80.sp),
                        padding: EdgeInsets.only(top: 90.sp),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: 20.sp, right: 20.sp, top: 20.sp),
                        //    margin: EdgeInsets.symmetric(horizontal: 5.sp),
                        //  margin: EdgeInsets.symmetric(horizontal: 20.sp),
                        child: SvgPicture.asset(
                          "assets/pigments.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                      onTap: () {
                        /*logEvent('pigments_tap',
                            {'action': 'navigated_to_new_home'});*/
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewHomeScreen(
                                // analytics: analytics,
                                ),
                          ),
                        );
                      },
                    ),
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.topRight,
                        // margin: EdgeInsets.symmetric(horizontal: 5.sp),
                        margin: EdgeInsets.symmetric(horizontal: 20.sp),
                        // margin: EdgeInsets.only(left: 20.sp, right: 20.sp),
                        child: SvgPicture.asset(
                          "assets/logout.svg",
                          fit: BoxFit.fill,
                        ),
                      ),
                      onTap: () async {
                        getToken();
                        print("userToken:" + userToken.toString());
                        print("employeeID:" + employeeId.toString());
                        _logout(employeeId.toString(), userToken!);
                      },
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      /*margin: EdgeInsets.symmetric(
                            horizontal: 20.sp,
                          ),*/
                      child: Image.asset(
                        "assets/sudarshan.png",
                      ),
                    ),
                  ],
                ))
          ]));
    });
  }

  /*Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }*/
  Future<void> logEvent1(String name, Map<String, dynamic> parameters) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );

      print("Logged event: $name with parameters: $parameters");
    } catch (e) {
      print("Failed to log event: $e");
    }
  }

  Future<void> logEvent() async {
    try {
      await analytics.setCurrentScreen(screenName: 'Pigments');
      await analytics.setUserId(id: "888999");
    } catch (e) {
      print("Failed to log event: $e");
    }
  }

  Future<void> getToken() async {
    userToken = await DatabaseHelper().getToken1(context);
    employeeId = (await DatabaseHelper().getEmployeeID());
    //userToken = "1E5O3tCJuz03bib";
    print("Token:" + userToken!);
    // _categoriesStream = categoryRepo.getCategoryStream(userToken.toString());
  }

  Future<void> _logout(String employeeId, String token) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {
      'employee_id': employeeId,
      Constant.UserToken: token,
      //'apiKey': "8c961641025d48b7b89d475054d656da"
      Constant.apiKey: Constant.apiKey_value
    };

    var response = await http.post(
        //  Uri.parse("https://sudapedia.sudarshan.com/Admin/web-api/logout.php"),
        Uri.parse(Constant.url + Constant.url_logout),
        headers: headers,
        body: body);
    print(response.body.toString());
    print(response.body);
    //if (response.body.contains("Logout Successfully !!")) {
    //if (response.body.contains("Inavlid User Token Key")) {
    if (response.body.contains("Inavlid User Token Key") ||
        response.body.contains("Logout Successfully !!")) {
      final jsonResponse = jsonDecode(response.body);
      if ((jsonResponse['msg'] == 'Logout Successfully !!') ||
          (jsonResponse['msg'] == 'Inavlid User Token Key')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['msg'])),
        );
        DatabaseHelper dbHelper = DatabaseHelper();
        dbHelper.clearTable();
        getToken();

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
