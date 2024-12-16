import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Pigments.dart';
import 'package:sudapedia/SendOTP.dart';

/*void main() {
  runApp(const MyApp());
}*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      new FirebaseAnalyticsObserver(analytics: firebaseAnalytics);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudapedia',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Montserrat'),
      //  navigatorObservers: [SessionNavigatorObserver()],
      navigatorObservers: <NavigatorObserver>[observer],
      /* home: const MyHomePage(
        title: 'Sudapedia',
      ),*/
      home: new MyHomePage(
          firebaseAnalytics: firebaseAnalytics, observer: observer),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  //const MyHomePage({super.key, required this.title});
  final FirebaseAnalytics firebaseAnalytics;
  final FirebaseAnalyticsObserver observer;
  MyHomePage({required this.firebaseAnalytics, required this.observer});
  //final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () => _checkTokenAndRedirect(context));
    initMixpanel();
    //  _getUserLocationAndCity();
  }

  late Mixpanel mixpanel;
  String _city = 'Loading...';

  Future<void> initMixpanel() async {
    /*mixpanel = await Mixpanel.init(
      "62ddf5b857e7c7599006c1200e6d2680",
      trackAutomaticEvents: false,
    );*/
    //late Mixpanel mixpanel;
    // mixpanel = await Mixpanel.init("62ddf5b857e7c7599006c1200e6d2680");
    mixpanel = await Mixpanel.init("74e0d8e0c7c5a746e5fbca830902f411");
    //mixpanel = await Mixpanel.init("ce929324ba3b21726809dc3bb81bde27");
    final dbHelper = DatabaseHelper();
    final employeeID = await dbHelper.getEmployeeID();
    print("employeeId:" + employeeID.toString());
    mixpanel.identify(employeeID.toString());
    mixpanel.track("User Logged In",
        properties: {"platform": "Android", "login_method": "email"});
    // disable geolocation from IP parsing
    mixpanel.setUseIpAddressForGeolocation(true);

    mixpanel.setLoggingEnabled(true);
  }

  // Send city to Mixpanel
  void _sendCityToMixpanel(String city) {
    mixpanel.track('User Location', properties: {
      'city': city,
    });
  }

  // Get the user's location and city
  Future<void> _getUserLocationAndCity() async {
    try {
      Position position = await _getUserLocation();
      String? city =
          await _getCityFromCoordinates(position.latitude, position.longitude);

      if (city != null) {
        setState(() {
          _city = city;
        });

        // Send the city data to Mixpanel
        _sendCityToMixpanel(city);
        print("City: $city");
      } else {
        setState(() {
          _city = 'City not found';
        });
      }
    } catch (e) {
      setState(() {
        _city = 'Error fetching location';
      });
      print('Error: $e');
    }
  }

  // Get user's location
  Future<Position> _getUserLocation() async {
    PermissionStatus permission1 = await Permission.location.request();

    if (permission1.isDenied) {
      print('Location permission is denied.');
      return Future.error('Location permission is denied.');
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return Future.error('Location permission is denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Get city name from latitude and longitude (reverse geocoding)
  Future<String?> _getCityFromCoordinates(
      double latitude, double longitude) async {
    final String apiKey =
        'AIzaSyBPSsJhQJsB2Dqd7X36Pt8jSaLSK3aWrE4'; // Replace with your actual Google Maps API key
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];

        if (results.isNotEmpty) {
          for (var result in results) {
            for (var component in result['address_components']) {
              if (component['types'].contains('locality')) {
                return component['long_name']; // City name
              }
            }
          }
        }
        return null; // If no city found
      } else {
        return null;
      }
    } catch (e) {
      print('Error during geocoding: $e');
      return null;
    }
  }

  void _checkTokenAndRedirect(BuildContext context) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    try {
      String? token = await dbHelper.getToken1(context);

      if (token == null) {
        print("Token is expired or not present.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SendOTP()),
        );
      } else {
        // Token is valid, proceed with your logic
        print("Token is valid: $token");
        //  currentScreen();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  //Pigments(analytics: MyApp.firebaseAnalytics)),
                  Pigments()),
        );
      }
    } catch (e) {
      // Handle potential errors (e.g., show an error message)
      print("Error checking token: $e");
    }
  }

  //FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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

  Future<void> sendAnalytics(
      {required String eventName, Map<String, dynamic>? parameters}) async {
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  Future<Null> currentScreen() async {
    await widget.firebaseAnalytics.setCurrentScreen(
      screenName: 'Pigments',
    );
  }
}
