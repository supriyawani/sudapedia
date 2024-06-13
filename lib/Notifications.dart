import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/repository/Notification_repo.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var isLoading = false;

  String? userToken; // Replace with actual user token
  StreamController? _postsController;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void initState() {
    // TODO: implement initState
    super.initState();
    _postsController = StreamController();
    getToken();
  }

  Future<void> getToken() async {
    userToken = (await DatabaseHelper().getToken())!;
    print("Token:" + userToken!);
    loadPosts();
  }

  // _CategoryDetailsState(this.id);

  loadPosts() async {
    var apiProvider = Notification_repo();
    apiProvider.getNotification(userToken.toString()).then((res) async {
      _postsController?.add(res);
      return res;
    });
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
            Container(
              child: Column(
                children: [
                  Container(
                    color: Constant.getColor("A"),
                    width: double.infinity, // Span the full width
                    child: Image.asset(
                      'assets/appbar_logo.png',
                      fit: BoxFit.contain, // Adjust fit as needed
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.only(top: 5.sp, bottom: 5.sp, left: 15.sp),
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
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: _postsController!.stream,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          print("Error: ${snapshot.error}");
                          return Center(
                            child: Text(
                              "Error fetching data",
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (snapshot.hasData && snapshot.data != null) {
                          print("Data: ${snapshot.data}");
                          List<dynamic> dataList = snapshot.data;
                          return ListView.builder(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: dataList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                  margin: EdgeInsets.all(8.sp),
                                  /* margin: EdgeInsets.only(
                                      top: 3.sp,
                                      left: 8.sp,
                                      right: 8.sp,
                                      bottom: 5.sp),*/
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
                                          //  child: Container(
                                          //   color: Colors.white,
                                          child: ListTile(
                                            title: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  color: Colors.white,
                                                  // elevation: 5.sp,
                                                  // child: Container(
                                                  alignment: Alignment.center,
                                                  /*   margin: EdgeInsets.only(
                                              top: 10.sp,
                                              left: 5.sp,
                                              right: 5.sp,
                                            ),*/
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Container(
                                                        margin: EdgeInsets.all(
                                                            3.sp),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            /*   Text(
                                                              dataList[index]
                                                                  .title,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),*/
                                                            /* Text(dataList[index]
                                                                .createdDate),*/
                                                          ],
                                                        ),
                                                      ),
                                                      /*Container(
                                                        margin: EdgeInsets.all(
                                                            5.sp),
                                                        child: Text(
                                                          dataList[index]
                                                              .createdDate,
                                                        ),
                                                      ),*/
                                                      Container(
                                                        margin: EdgeInsets.all(
                                                            2.sp),
                                                        child: Text(
                                                          dataList[index]
                                                              .nottifications,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.all(
                                                            1.sp),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            /*  TextButton(
                                                              onPressed: () {},
                                                              child: Text(
                                                                "Read More",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                            ),*/
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .all(5.sp),
                                                              child: Text(
                                                                dataList[index]
                                                                    .createdDate,
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .all(5.sp),
                                                              child: Text(
                                                                dataList[index]
                                                                    .createdTime,
                                                              ),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          8.sp),
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xFF000080),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5.sp))),

                                                              //  onPressed: () {},
                                                              child: Text(
                                                                dataList[index]
                                                                    .type,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
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
                                          ))));
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
    });
  }

/* return ListTile(
                            title: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.all(10.sp),
                                      child: Card(
                                          elevation: 5.sp,
                                          child: Container(
                                              alignment: Alignment.center,
                                              // height: 18.h,
                                              margin: EdgeInsets.only(
                                                  top: 10.sp,
                                                  left: 5.sp,
                                                  right: 5.sp),
                                              child: Column(
                                                //mainAxisSize: MainAxisSize.max,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.all(5.sp),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(
                                                            ' ${notification.notificationTitle}',
                                                            style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              overflow: TextOverflow
                                                                  .ellipsis,
                                                            ),
                                                          ),
                                                          /*  Text(
                                                          ' ${notification.time}'),*/
                                                          Text(
                                                              ' ${notification.date}'),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                        margin:
                                                        EdgeInsets.all(5.sp),
                                                        child: Text(
                                                          ' ${notification.title}',
                                                        )),
                                                    Container(
                                                        margin:
                                                        EdgeInsets.all(5.sp),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                String
                                                                notificationType =
                                                                notification
                                                                    .type
                                                                    .toString();
                                                                if (notificationType ==
                                                                    Constant
                                                                        .NOTIFICATION_TYPE_MEETING) {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ClubMeeting(
                                                                              ClubName:
                                                                              ClubName,
                                                                              AccessLevel:
                                                                              AccessLevel,
                                                                              MemberId:
                                                                              MemberId,
                                                                              ClubId:
                                                                              ClubNumber)));
                                                                } else if (notificationType ==
                                                                    Constant
                                                                        .NOTIFICATION_TYPE_CELEBRATION_BIRTHDAY ||
                                                                    notificationType ==
                                                                        Constant
                                                                            .NOTIFICATION_TYPE_CELEBRATION_WEDDING) {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              ClubCelebrationList(
                                                                                ClubName:
                                                                                ClubName,
                                                                              )));
                                                                } else if (notificationType ==
                                                                    Constant
                                                                        .NOTIFICATION_TYPE_PROJECT) {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ClubProject(
                                                                              ClubName:
                                                                              ClubName,
                                                                              AccessLevel:
                                                                              AccessLevel,
                                                                              MemberId:
                                                                              MemberId,
                                                                              ClubId:
                                                                              ClubNumber)));
                                                                } else if (notificationType ==
                                                                    Constant
                                                                        .NOTIFICATION_TYPE_EVENT) {
                                                                  Constant
                                                                      .displayToast(
                                                                      "");
                                                                }
                                                              },
                                                              child: Text(
                                                                  "Read More",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .blue)),
                                                            ),
                                                            ElevatedButton(
                                                                style: ButtonStyle(
                                                                    foregroundColor:
                                                                    MaterialStateProperty.all<Color>(
                                                                        Colors
                                                                            .white),
                                                                    backgroundColor:
                                                                    MaterialStateProperty.all<
                                                                        Color>(
                                                                      buildNotificationTypeWidget(
                                                                          notification
                                                                              .type
                                                                              .toString()),
                                                                    ),
                                                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius.circular(5
                                                                            .sp),
                                                                        side: BorderSide(
                                                                            color:
                                                                            buildNotificationTypeWidget(notification.type.toString()))))),
                                                                onPressed: () {},
                                                                child: Text(
                                                                  ' ${notification.type}',
                                                                ))
                                                          ],
                                                        )),
                                                  ]))))
                                ]));*/
}
