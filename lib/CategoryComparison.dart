import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Model/ComparisonResponse.dart';
import 'package:sudapedia/PDFSubCategory.dart';
import 'package:sudapedia/SessionTimeoutManager.dart';
import 'package:sudapedia/repository/Comparison_repo.dart';

class CategoryComparison extends StatefulWidget {
  final String id, code;

  CategoryComparison({required this.id, required this.code});

  @override
  _CategoryComparisonState createState() => _CategoryComparisonState(id, code);
}

class _CategoryComparisonState extends State<CategoryComparison> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<ComparisonResponse>? futureCategoryResponse;
  String? userToken;
  String id, code;
  String? categoryName = "";

  _CategoryComparisonState(this.id, this.code);

  @override
  void initState() {
    super.initState();
    getToken();
    _prefs.then((SharedPreferences prefs) async {
      id = prefs.getString('id')!;
      code = prefs.getString('code')!;
    });
    print("id:" + id);
    print("code:" + code);
    // loadPreferences();
    /*  futureCategoryResponse = Comparison_repo()
        .fetchCategoryData(userToken.toString(), id.toString());
*/
  }

  Future<void> getToken() async {
    userToken = await DatabaseHelper().getToken();
    print("Token:" + userToken!);
    getCategoryName();
    loadPreferences();
  }

  void loadPreferences() async {
    /* SharedPreferences prefs = await _prefs;
    setState(() {
      id = prefs.getString('id') ?? '';
      code = prefs.getString('code') ?? '';
    });*/
    setState(() {
      futureCategoryResponse = Comparison_repo()
          .fetchCategoryData(userToken.toString(), id.toString());
    });
  }

  void getCategoryName() async {
    Comparison_repo()
        .getCategoryName(userToken.toString(), id.toString())
        .then((result) {
      if (result != null) {
        setState(() {
          print("result:" + result.toString());
          categoryName = result.toString();
          print("categoryName:" + categoryName.toString());
          // loadPosts();
        });

        // saveData(result);
      } else {
        setState(() {
          // Constant.displayToast("please enter valid credentials!");
        });
      }
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
        }, child: Sizer(
          builder: (context, orientation, deviceType) {
            return Scaffold(
              key: _scaffoldKey,
              body: Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/background_image.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Column(children: [
                    Container(
                      color: Constant.getColor(code),
                      width: double.infinity,
                      child: Image.asset(
                        'assets/appbar_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 5.sp, bottom: 5.sp),
                      color: Constant.getColor(code),
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          categoryName.toString(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<ComparisonResponse>(
                        future: futureCategoryResponse,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Center(child: Text('No Data Available'));
                          }

                          ComparisonResponse category = snapshot.data!;
                          return Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: StaggeredGridView.countBuilder(
                              crossAxisCount: 3,
                              crossAxisSpacing: 3.w,
                              mainAxisSpacing: 3.h,
                              itemCount: category.subcategories.length,
                              itemBuilder: (context, index) {
                                Subcategory subcategory =
                                    category.subcategories[index];
                                return Container(
                                  //color: Colors.white,
                                  //elevation: 3,
                                  child: Container(
                                    //color: Colors.white,
                                    padding: EdgeInsets.all(2.sp),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5.sp)),
                                          // Color applied here
                                          margin: EdgeInsets.only(bottom: 5.sp),
                                          child: Container(
                                            height: 8.h,
                                            padding: EdgeInsets.all(10.sp),
                                            margin: EdgeInsets.all(3.sp),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFEAEA),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5.sp),
                                                topRight: Radius.circular(5.sp),
                                                bottomLeft:
                                                    Radius.circular(5.sp),
                                                bottomRight:
                                                    Radius.circular(5.sp),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                subcategory.name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.sp,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 5.w,
                                          runSpacing: 1.h,
                                          children: subcategory.colorCodes
                                              .asMap()
                                              .map((i, colorCode) {
                                                Color color = Color.fromRGBO(
                                                  int.parse(colorCode.code
                                                      .split('/')[0]
                                                      .substring(1)),
                                                  int.parse(colorCode.code
                                                      .split('/')[1]
                                                      .substring(1)),
                                                  int.parse(colorCode.code
                                                      .split('/')[2]
                                                      .substring(1)),
                                                  1,
                                                );
                                                return MapEntry(
                                                  i,
                                                  Column(
                                                    children: [
                                                      Container(
                                                        /*  margin: EdgeInsets.only(
                                                        top: 8.sp),*/
                                                        // color: Colors.white,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.sp)),
                                                        child: Center(
                                                            child: Container(
                                                                //   color: Colors.white,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left: 5
                                                                            .sp),
                                                                child: Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              Container(
                                                                        child:
                                                                            Text(
                                                                          colorCode
                                                                              .title,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                10.sp,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                      IconButton(
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .download_for_offline_outlined,
                                                                          size:
                                                                              18.sp,
                                                                          color:
                                                                              Colors.blue,
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => PDFSubCategory(
                                                                                id: id,
                                                                                code: code.toString(),
                                                                                subcat_id: subcategory.id.toString(),
                                                                                color_id: colorCode.id,
                                                                                categoryName: categoryName.toString(),
                                                                                color_code_id: "0",
                                                                              ),
                                                                            ),
                                                                          );

                                                                          // Handle the download action
                                                                        },
                                                                      ),
                                                                    ]))),
                                                        /* onTap: () {
                                                      */ /* Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PDFSubCategory(
                                                            id: id,
                                                            code:
                                                                code.toString(),
                                                            subcat_id:
                                                                subcategory.id
                                                                    .toString(),
                                                            color_id:
                                                                colorCode.id,
                                                            categoryName:
                                                                categoryName
                                                                    .toString(),
                                                            color_code_id: "0",
                                                          ),
                                                        ),
                                                      );*/ /*
                                                    },*/
                                                      ),
                                                      /* if (i <
                                                      subcategory.colorCodes
                                                              .length -
                                                          1)
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            left: 5.sp,
                                                            right: 5.sp),
                                                        child: Divider(
                                                          color: Colors.black,
                                                          thickness: 0.9,
                                                        )),*/
                                                    ],
                                                  ),
                                                );
                                              })
                                              .values
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              staggeredTileBuilder: (index) =>
                                  StaggeredTile.fit(1),
                            ),
                          );
                        },
                      ),
                    ),
                  ])
                ],
              ),
            );
          },
        )));
  }
}
