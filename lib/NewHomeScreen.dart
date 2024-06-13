import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/CategoryComparison.dart';
import 'package:sudapedia/CategoryDetails.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Model/CategoriesResponse.dart';
import 'package:sudapedia/Notifications.dart';
import 'package:sudapedia/SessionTimeoutManager.dart';
import 'package:sudapedia/SubCategory.dart';
import 'package:sudapedia/SubCategoryButtons.dart';
import 'package:sudapedia/repository/Category_repo.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({Key? key}) : super(key: key);

  @override
  _NewHomeScreenState createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<CategoriesResponse> categories;
  final categoryRepo = Category_repo();
  Stream<List<CategoriesResponse>> _categoriesStream = Stream.value([]);
  String? userToken, employeeId;

  //late Future<void> _initTokenFuture;
  Timer? _logoutTimer;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  void dispose() {
    //_logoutTimer?.cancel();
    super.dispose();
  }

  Future<void> getToken() async {
    userToken = await DatabaseHelper().getToken();
    //userToken = "1E5O3tCJuz03bib";
    print("Token:" + userToken!);
    // _categoriesStream = categoryRepo.getCategoryStream(userToken.toString());
    setState(() {
      _categoriesStream = categoryRepo.getCategoryStream(userToken.toString());
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
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.notifications,
                              size: 30.sp, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Notifications(),
                              ),
                            );
                          },
                        ))),
                StreamBuilder<List<CategoriesResponse>>(
                  stream: _categoriesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No categories available'));
                    } else {
                      final categories = snapshot.data!;
                      return Padding(
                        padding: EdgeInsets.only(top: 150.0),
                        // Adjust top padding to avoid overlap with the image
                        child: GridView.builder(
                          padding: EdgeInsets.all(15.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                onTap: () {
                                  if (categories[index].flag.toString() ==
                                      "0") {
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
                                  } else if (categories[index]
                                          .flag
                                          .toString() ==
                                      "3") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SubCategoryButtons(
                                          categoryName: categories[index]
                                              .categoryName
                                              .toString(),
                                          id: categories[index].id.toString(),
                                          code:
                                              categories[index].code.toString(),
                                          subcat_id: "0",
                                        ),
                                      ),
                                    );
                                  } else if (categories[index]
                                          .flag
                                          .toString() ==
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
                                            code: categories[index]
                                                .code
                                                .toString()),
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
        })));
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
          // borderRadius: BorderRadius.circular(0.1),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF221750)
                  .withOpacity(0.18), // Opacity adjusted based on Figma value
              offset: Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
            /* BoxShadow(
              color: Color(0xFF18174E)
                  .withOpacity(0.25), // Opacity adjusted based on Figma value
              offset: Offset(0, 3),
              blurRadius: 4,
              spreadRadius: 0,
            ), -Inner boxshadow
            */
          ],
        ),
        child: ClipRRect(
          //   borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: getGradient(category.code.toString()),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white,
                width: 10.sp,
              ),
            ),
            child: Center(
              child: Container(
                // margin: EdgeInsets.symmetric(horizontal: 15.sp),
                margin: EdgeInsets.only(left: 20.sp, right: 20.sp),
                child: Text(
                  category.categoryName.toString(),
                  style: TextStyle(
                      fontSize: 50.sp,
                      fontWeight: FontWeight.w400,
                      // color: Colors.black54),
                      color: Color(0xFF525252)),
                  textAlign: TextAlign.center,
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
        boxShadow:
        /*  [
          BoxShadow(
            //   color: Color(0xFF18174E)
            color: Colors.white38
                .withOpacity(0.25), // Opacity adjusted based on Figma value
            offset: Offset(0, -3),
            blurRadius: 4,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0xFF221750)
                .withOpacity(0.18), // Opacity adjusted based on Figma value
            offset: Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ];*/
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
