import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Model/CategoriesResponse.dart';
import 'package:sudapedia/Model/NotificationResponse.dart';
import 'package:sudapedia/repository/Category_repo.dart';

import 'CategoryComparison.dart';
import 'CategoryDetails.dart';
import 'Notifications.dart';
import 'SubCategory.dart';
import 'SubCategoryButtons.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  _NewHomeScreenState createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // late final List<CategoriesResponse> categories;
  late List<CategoriesResponse> categories;
  final categoryRepo = Category_repo();
  Stream<List<CategoriesResponse>> _categoriesStream = Stream.value([]);
  String? userToken, employeeId;
  //String? notificationCount;
  int? notificationCount;
  bool showBadge = true;
  //late Future<void> _initTokenFuture;
  Timer? _logoutTimer;
  int count = 0;
  String? groupID;

  List<NotificationArr> notifications = [];
  String? errorMessage;
  String? errorMessageForNotifications;
  String? errorMessageForCategories;
  late Stream<List<CategoriesResponse>> categoriesStream;

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addObserver(this);
    // notificationCountforBadge();
    /* logEvent('HomeScreen', {
      'employee_id': '888999',
    });*/
    logUserId();
    getToken();
    fetchnotifiication();
    Constant().initMixpanel("HomeScreen");

    //fetchnotifiication1();
    //categoriesStream = getCategoryStream();
  }

  Future<void> notificationCountforBadge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // notificationCount = prefs.getString('notificationcount');
    // notificationCount = "3";
    count = (await DatabaseHelper().getNotificationCount())!;
    notificationCount = count;
    //notificationCount = DatabaseHelper().getNotificationCount().toString();
    print("count:" + count.toString());
    setState(() {
      //notificationCount = prefs.getString('notificationcount');
      // notificationCount = prefs.getString('notificationcount') ?? "";
    });
  }

  Future<void> fetchnotifiication() async {
    String? UserToken = await DatabaseHelper().getToken1(context);
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var request = http.Request(
        'POST', Uri.parse(Constant.url + Constant.url_notification));

    request.bodyFields = {
      'apiKey': "8c961641025d48b7b89d475054d656da",
      'UserToken': UserToken.toString(),
    };
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);

    List<NotificationArr?> result;
    if (jsonData != null && jsonData['msg'] == "Inavlid User Token Key") {
      throw Exception('Invalid User Token Key');
    } else if (jsonData.toString().contains("Successfull !!")) {
      // If the response is a map and contains a key 'data'
      if (jsonData.containsKey('notifications_arr')) {
        final dynamic pdfData = jsonData['notifications_arr'];
        final List t = jsonData['notifications_arr'];
        final List<NotificationArr> userList =
            t.map((item) => NotificationArr.fromJson(item)).toList();
        result = userList.toSet().toList();
        print("Notificationcount:" + userList.length.toString());
        count = (await DatabaseHelper().getNotificationCount())!;
        //count = 1565;
        int Updatedcount = int.parse(userList.length.toString());
        //int Updatedcount = 1566;

        //notificationCount = Updatedcount - count;
        setState(() {
          notificationCount = Updatedcount - count;
        });

        print("Count:" + notificationCount.toString());
      } else {
        result = List.empty();
      }
    }
  }

  Future<void> fetchnotifiication1() async {
    try {
      String? userToken = await DatabaseHelper().getToken1(context);
      //  String userToken = 'userToken123'; // Replace with actual token fetching

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Constant.url + Constant.url_notification),
      );

      request.fields.addAll({
        Constant.apiKey: Constant.apiKey_value,
        Constant.UserToken: userToken.toString(),
      });

      http.StreamedResponse response = await request.send();
      var res = await response.stream.bytesToString();
      var jsonData = json.decode(res);

      if (jsonData != null && jsonData['msg'] == "Inavlid User Token Key") {
        setState(() {
          errorMessageForNotifications = 'Invalid User Token Key';
        });
      } else if (jsonData != null && jsonData['notifications_arr'] != null) {
        final List<dynamic> categoriesList = jsonData['notifications_arr'];
        setState(() {
          notifications = categoriesList
              .map((item) => NotificationArr.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      setState(() {
        errorMessageForNotifications = e.toString();
      });
    }
  }

  Stream<List<CategoriesResponse>> getCategoryStream1() async* {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(Constant.url + Constant.url_categories),
    );
    String? userToken = await DatabaseHelper().getToken1(context);
    //String? groupid = await DatabaseHelper().getGroupID();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? groupid = prefs.getString(Constant.groupID);
    request.fields.addAll({
      'apiKey': '8c961641025d48b7b89d475054d656da',
      'UserToken': userToken.toString(),
      Constant.groupID: groupid.toString(),
    });

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    var jsonData = json.decode(res);

    if (jsonData != null && jsonData['msg'] == "Inavlid User Token Key") {
      setState(() {
        errorMessageForCategories = 'Invalid User Token Key';
      });
    } else if (jsonData != null && jsonData['categories_arr'] != null) {
      final List<dynamic> categoriesList = jsonData['categories_arr'];
      yield categoriesList
          .map((item) => CategoriesResponse.fromJson(item))
          .toList();
    } else {
      yield [];
    }
  }

  @override
  void dispose() {
    //_logoutTimer?.cancel();
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> getToken() async {
    userToken = await DatabaseHelper().getToken1(context);

    print("Token:" + userToken!);

    /* String? groupId = await DatabaseHelper().getGroupID();
    print("groupID:" + groupId.toString());*/
    SharedPreferences prefs = await SharedPreferences.getInstance();
    groupID = prefs.getString(Constant.groupID);

    setState(() async {
      _categoriesStream = categoryRepo.getCategoryStream(
          userToken.toString(), groupID.toString());
    });
  }

  Future<void> resetNotificationCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationcount', "0");
    await DatabaseHelper().updateNotificationCount(0);
    setState(() {
      notificationCount = 0;
      count = 0;
      showBadge = false;
    });
  }
  /*Future<void> resetNotificationCount(NotificationProvider provider) async {
    provider.setNotificationCount(0);
  }*/

  @override
  Widget build(BuildContext context) {
    //count = int.tryParse(notificationCount!) ?? 0;
    // count = int.tryParse(notificationCount!)!;

    count = notificationCount ?? 0;
    print("count:" + count.toString());
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
                  image: AssetImage("assets/background_image.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 0, // Adjust top padding as needed
              left: 0,
              right: 0,
              child: Container(
                //  width: double.infinity, // Span the full width
                child: Image.asset(
                  'assets/appbar_logo.png',
                  fit: BoxFit.cover, // Adjust fit as needed
                ),
              ),
            ),
            Positioned(
                top: 0, // Adjust top padding as needed
                left: 0,
                right: 0,
                child: Container(
                    margin: EdgeInsets.only(top: 38.sp, right: 10.sp),
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          size: 20.sp, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ))),
            Positioned(
                top: 0, // Adjust top padding as needed
                left: 0,
                right: 0,
                child: GestureDetector(
                  child: Container(
                      margin: EdgeInsets.only(top: 30.sp, right: 10.sp),
                      alignment: Alignment.topRight,
                      child: Stack(
                        children: [
                          IconButton(
                              icon: Icon(Icons.notifications,
                                  size: 35.sp, color: Colors.orange),
                              onPressed: () async {
                                resetNotificationCount();
                                setState(() {
                                  showBadge = false; // Hide badge on icon click
                                });
                                //  resetNotificationCount();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Notifications(),
                                  ),
                                );
                              }),
                          if (showBadge && count > 0)
                            Positioned(
                              right: 0,
                              child: Container(
                                margin: EdgeInsets.only(right: 2.sp),
                                padding: EdgeInsets.all(5.sp),
                                decoration: BoxDecoration(
                                  color: Colors.red, // Choose your badge color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  notificationCount.toString(),
                                  // Your notification count
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )),
                  onTap: () {
                    resetNotificationCount();
                    setState(() {
                      showBadge = false; // Hide badge on icon click
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Notifications(),
                      ),
                    );
                  },
                )),
            StreamBuilder<List<CategoriesResponse>>(
              stream: _categoriesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No categories available'));
                } else if (snapshot.hasError) {
                  Utils.handleInvalidToken(context, snapshot.error);
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final categories = snapshot.data!;

                  return Padding(
                    padding: EdgeInsets.only(top: 150.0),
                    // Adjust top padding to avoid overlap with the image
                    child: GridView.builder(
                      padding: EdgeInsets.all(15.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 30.0,
                        childAspectRatio: 4 / 2,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            child: CategoryItem(
                              category: categories[index],
                            ),
                            onTap: () async {
                              if (categories[index].flag.toString() == "0") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SubCategory(
                                              id: categories[index]
                                                  .id
                                                  .toString(),
                                              code: categories[index]
                                                  .code
                                                  .toString(),
                                            )));
                              } else if (categories[index].flag.toString() ==
                                  "3") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubCategoryButtons(
                                      categoryName: categories[index]
                                          .categoryName
                                          .toString(),
                                      id: categories[index].id.toString(),
                                      code: categories[index].code.toString(),
                                      subcat_id: "0",
                                    ),
                                  ),
                                );
                              } else if (categories[index].flag.toString() ==
                                  "2") {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryComparison(
                                              id: categories[index]
                                                  .id
                                                  .toString(),
                                              code: categories[index]
                                                  .code
                                                  .toString(),
                                            )));
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryDetails(
                                        id: categories[index].id.toString(),
                                        code:
                                            categories[index].code.toString()),
                                  ),
                                );
                              }
                            });
                      },
                    ),
                  );
                }
              },
            ),
          ]));
    });
  }

  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> logUserId() async {
    employeeId = (await DatabaseHelper().getEmployeeID());
    print("employeeId:" + employeeId.toString());
    await analytics.setUserId(id: employeeId);
  }
}

class CategoryItem extends StatelessWidget {
  final CategoriesResponse category;

  //final VoidCallback onTap;

  CategoryItem({
    required this.category,
    /*required this.onTap*/
  });

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.sp, vertical: 5.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0.1),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF221750).withOpacity(0.18), // Outer shadow
              offset: Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              gradient: getGradient(category.code.toString()),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white,
                width: 10.sp,
              ),
            ),
            child: InnerShadow(
              shadows: [
                Shadow(
                  color: Color(0xFF18174E).withOpacity(0.25), // Inner shadow
                  offset: Offset(0, 5), // Adjust offset as needed
                  blurRadius: 12,
                ),
              ],
              child: Center(
                child: Container(
                  margin: EdgeInsets.only(left: 20.sp, right: 20.sp),
                  child: Text(
                    category.categoryName.toString(),
                    style: TextStyle(
                      fontSize: 50.sp,
                      //  fontWeight: FontWeight.w400,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF525252),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  LinearGradient getGradient(String code) {
    List<Color> colors = [];
    List<double> stops = [];
    // BoxShadow boxShadow;
    switch (code) {
      case 'A':
        colors = [Color(0xFFFFC6C6), Color(0xFFFF8888)];
        stops = [0.0, 1.0];

        break;
      case 'B':
        colors = [Color(0xFFFFD4A3), Color(0xFFFFBB6D)];
        stops = [0.0, 1.0];

        break;
      case 'C':
        colors = [Color(0xFFBFFFE8), Color(0xFF38FFB7)];
        stops = [0.0, 1.0];

        break;
      case 'D':
        colors = [Color(0xFFD8FFA6), Color(0xFFACFF42)];
        stops = [0.6, 1.0];

        break;
      case 'E':
        colors = [Color(0xFF92C4FF), Color(0xFF50A0FF)];
        stops = [0.0, 1.0];

        break;
      case 'F':
        colors = [Color(0xFFD2FCFF), Color(0xFF71F7FF)];
        stops = [0.45, 1.0];

        break;
      case 'G':
        colors = [Color(0xFFFFA4C5), Color(0xFFFF5A95)];
        // colors = [Color(0xFF), Color(0xFF)];
        stops = [0.0, 0.1];

        break;
      case 'H':
        colors = [Color(0xFFDBADFF), Color(0xFFC478FF)];
        stops = [0.0, 1.0];

        break;
      case 'I':
        colors = [Color(0xFFFF9B9B), Color(0xFFFF6464)];
        stops = [0.26, 1.0];

        break;
      case 'J':
        colors = [Color(0xFFFFA4C5), Color(0xFFFF5A95)];
        stops = [0.0, 1.0];

        break;
      // Add more cases for other color codes as needed
      default:
        colors = [Color(0xFFFFA4C5), Color(0xFFFF5A95)];
        stops = [0.0, 1.0];
    }

    return LinearGradient(
      colors: colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
