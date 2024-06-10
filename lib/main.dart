import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Pigments.dart';
import 'package:sudapedia/SendOTP.dart';
import 'package:sudapedia/SessionTimeoutManager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudapedia',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Montserrat'),
      home: const MyHomePage(
        title: 'Sudapedia',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*@override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _navigateToNextScreen();
    */ /* Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SendOTP())));*/ /*
  }*/

  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () => _checkSession());
  }

  void _checkSession() async {
    bool isLoggedIn = await SessionManager.isUserLoggedIn();
    print("isLoggedIn:" + isLoggedIn.toString());
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Pigments()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SendOTP()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

    return Sizer(builder: (context, orientation, deviceType) {
      return Scaffold(
          key: _scaffoldKey,
          body: Stack(children: <Widget>[
            Container(
              padding: EdgeInsets.all(0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/splash_image.png",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            )
          ]));
    });
  }
}
