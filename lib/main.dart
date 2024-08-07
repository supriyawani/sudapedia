import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Pigments.dart';
import 'package:sudapedia/SendOTP.dart';

void main() {
  runApp(const MyApp());
  /* runApp(
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: MyApp(),
    ),
  );*/
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
      //  navigatorObservers: [SessionNavigatorObserver()],
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
  void initState() {
    super.initState();
    /*  Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Pigments())));*/
    //Timer(Duration(seconds: 3), () => _checkSession());
    Timer(Duration(seconds: 3), () => _checkTokenAndRedirect(context));
  }

  void _checkTokenAndRedirect(BuildContext context) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    String? token = await dbHelper.getToken1(context);

    if (token == null) {
      // Token is either expired or not present, the user is already redirected to SendOTP
      print("Token is expired or not present.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SendOTP()),
      );
    } else {
      // Token is valid, proceed with your logic
      print("Token is valid: $token");
      // Proceed to the desired screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Pigments()),
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
