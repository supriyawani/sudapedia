import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/BackgroundWithLogo.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Model/NotificationResponse.dart';
import 'package:sudapedia/SessionTimeoutManager.dart';
import 'package:sudapedia/repository/Notification_repo.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var isLoading = false;
  String? query;
  String? userToken; // Replace with actual user token
  //StreamController? _postsController;
  StreamController<List<NotificationArr?>>? _postsController;
  final TextEditingController _searchController = TextEditingController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void initState() {
    // TODO: implement initState
    super.initState();
    // _postsController = StreamController();
    _postsController = StreamController<List<NotificationArr?>>();
    getToken();
    setState(() {});
  }

  Future<void> getToken() async {
    userToken = (await DatabaseHelper().getToken1(context))!;
    //userToken = "953Qi5k8I3T0voK";
    print("Token:" + userToken!);
    setState(() {
      loadPosts();
    });
  }

  // _CategoryDetailsState(this.id);

  loadPosts(/*[String query = ""]*/) async {
    /*var apiProvider = Notification_repo();
    apiProvider
        .getNotification(
      userToken.toString(),
    )
        .then((res) async {
      _postsController?.add(res);
      return res;
    });*/
    var apiProvider = Notification_repo();
    try {
      var res = await apiProvider.getNotification(userToken.toString());
      if (res.contains(Constant.invalidToken)) {
        Constant.navigatetoSendotp(context);
      } else {
        _postsController?.add(res);
      }
    } catch (e) {
      print("Error loading posts: $e");
      Constant.navigatetoSendotp(context);
      // Handle error loading posts
    }
  }

  loadPostseasrch([String query = ""]) async {
    var apiProvider = Notification_repo();
    apiProvider
        .getseachNotification(
      userToken.toString(),
      query.toString(),
    )
        .then((res) async {
      _postsController?.add(res);
      return res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => SessionTimeoutManager.resetLogoutTimer(context),
        child: WillPopScope(onWillPop: () async {
          SessionTimeoutManager.resetLogoutTimer(context);
          return true;
        }, child: Sizer(builder: (context, orientation, deviceType) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            key: _scaffoldKey,
            body: Stack(
              children: <Widget>[
                /* Container(
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
                ),*/
                BackgroundWithLogo(code: "A"),
                Container(
                  child: Column(
                    children: [
                      /*  Container(
                        color: Constant.getColor("A"),
                        width: double.infinity, // Span the full width
                        child: Image.asset(
                          'assets/appbar_logo.png',
                          fit: BoxFit.contain, // Adjust fit as needed
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: 5.sp, bottom: 5.sp, left: 15.sp),
                        color: Constant.getColor("A"),
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "Notification",
                            style: TextStyle(
                              fontSize: 18.sp,
                              //fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),*/
                      CustomAppBar(categoryName: "Notifications", code: "A"),
                      Container(
                        padding: EdgeInsets.all(8.sp),
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search Notifications",
                          ),
                          onChanged: (value) {
                            //   loadPostseasrch();
                            setState(() {
                              loadPostseasrch(value);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<List<NotificationArr?>>(
                          stream: _postsController!.stream,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<NotificationArr?>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            /*else if (snapshot.hasError) {
                              print("Error: ${snapshot.error}");
                              return Center(
                                child: Text(
                                  "Error fetching data",
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            } */
                            else if (snapshot.hasError) {
                              Utils.handleInvalidToken(context, snapshot.error);
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              print("Data: ${snapshot.data}");
                              List<NotificationArr?> dataList = snapshot.data!;
                              return ListView.builder(
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: dataList.length,
                                itemBuilder: (context, index) {
                                  var notification = dataList[index];
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: 8.sp,
                                        right: 8.sp,
                                        top: 8.sp,
                                        bottom: 8.sp),
                                    //margin: EdgeInsets.all(8.sp),
                                    child: Card(
                                      elevation: 5,
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                        ),
                                        child: ListTile(
                                          title: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      margin:
                                                          EdgeInsets.all(3.sp),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          // Add your UI components here
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          EdgeInsets.all(2.sp),
                                                      child: Text(
                                                        notification
                                                                ?.nottifications ??
                                                            "",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          EdgeInsets.all(1.sp),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5.sp),
                                                            child: Text(
                                                              notification
                                                                      ?.createdDate ??
                                                                  "",
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5.sp),
                                                            child: Text(
                                                              notification
                                                                      ?.createdTime ??
                                                                  "",
                                                            ),
                                                          ),
                                                          Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.sp),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFF000080),
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          5.sp)),
                                                            ),
                                                            child: Text(
                                                              notification
                                                                      ?.type ??
                                                                  "",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: Text(
                                  "No data available",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        })));
  }
}
