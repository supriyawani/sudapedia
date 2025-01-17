import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/BackgroundWithLogo.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/SubCategoryButtons.dart';
import 'package:sudapedia/repository/CategoryDetails_repo.dart';

class SubCategory extends StatefulWidget {
  String id, code;

  SubCategory({required this.id, required this.code});

  @override
  _SubCategoryState createState() => _SubCategoryState(id, code);
}

class _SubCategoryState extends State<SubCategory> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //String userToken = "FTGHI2W8XS"; // Replace with actual user token
  String? userToken; // Replace with actual user token
  StreamController? _postsController;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String id = "", code = "";
  String? categoryName = "";

  _SubCategoryState(String id, String code) {
    this.id = id;
    this.code = code;
  }

  @override
  initState() {
    super.initState();
    _postsController = new StreamController();
    getToken();

    // futurePdfCategory = pdfRepository.fetchPdfCategory(userToken);

    _prefs.then((SharedPreferences prefs) async {
      id = prefs.getString('id')!;
      code = prefs.getString('code')!;
    });

    print("id:" + id);
    print("code:" + code);
  }

  logevent() {
    Constant.logCategoryItemTap(
      categoryId: id,
      categoryName: categoryName.toString(),
    );
  }

  Future<void> getToken() async {
    userToken = (await DatabaseHelper().getToken1(context))!;
    //userToken = "953Qi5k8I3T0voK";
    getCategoryName();

    // loadPosts();
    print("Token:" + userToken!);
  }

  // _CategoryDetailsState(this.id);

  loadPosts() async {
    var apiProvider = CategoryDetails_repo();
    apiProvider
        .getSubCategory(userToken.toString(), id.toString())
        .then((res) async {
      _postsController?.add(res);
      return res;
    });
  }

  void getCategoryName() async {
    /*CategoryDetails_repo()
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
    });*/
    try {
      String? result = await CategoryDetails_repo()
          .getCategoryName(userToken.toString(), widget.id);
      if (result != null) {
        setState(() {
          print("result:" + result.toString());
          categoryName = result.toString();
          print("categoryName:" + categoryName.toString());
          Constant.logCategoryItemTap(
            categoryId: id,
            categoryName: categoryName.toString(),
          );
          Constant().initMixpanel(categoryName.toString());
          loadPosts();
        });
      }
    } catch (e) {
      print("Exception occurred: $e");

      Constant.navigatetoSendotp(context);
    }
  }

  Color innerDropShadowColor = Color(0xFF221750);
  Color innerShadowColor = Color(0xFF18174E);

  @override
  Widget build(BuildContext context) {
    return /* GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => SessionTimeoutManager.resetLogoutTimer(context),
        child: WillPopScope(onWillPop: () async {
          SessionTimeoutManager.resetLogoutTimer(context);
          return true;
        }, child: */
        Sizer(builder: (context, orientation, deviceType) {
      return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            BackgroundWithLogo(
              code: code.toString(),
            ),
            Container(
              child: Column(
                children: [
                  CustomAppBar(
                      categoryName: categoryName.toString(), code: code),
                  Expanded(
                      child: StreamBuilder(
                    stream: _postsController!.stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                        return Container(
                            //  margin: EdgeInsets.only(top: 50.sp),
                            margin: EdgeInsets.only(top: 10.sp),
                            // alignment: Alignment.topCenter,
                            child: ListView.builder(
                                //physics: NeverScrollableScrollPhysics(),
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: dataList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 10.sp,
                                          right: 10.sp,
                                          top: 15.sp),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.sp),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF221750)
                                                .withOpacity(0.10),
                                            // Opacity adjusted based on Figma value
                                            offset: Offset(0, 3),
                                            blurRadius: 6,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: InnerShadow(
                                          shadows: [
                                            Shadow(
                                              color: Color(0xFF18174E)
                                                  .withOpacity(0.25),
                                              // Inner shadow
                                              offset: Offset(0, 2),
                                              // Adjust offset as needed
                                              blurRadius: 4,
                                            ),
                                          ],
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: SvgPicture.asset(
                                                  "assets/subcategory_application.svg",
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              ListTile(
                                                contentPadding: EdgeInsets.only(
                                                    left: 5.sp,
                                                    right: 5.sp,
                                                    bottom: 10.sp,
                                                    top: 10.sp),
                                                title: Center(
                                                    child: Text(
                                                  dataList[index]
                                                          .subCategoryName ??
                                                      'No Name',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    // fontSize: 15.sp,
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.bold,
                                                    // Replace with your desired color
                                                  ),
                                                )),
                                              ),
                                            ],
                                          )),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SubCategoryButtons(
                                            categoryName:
                                                categoryName.toString(),
                                            id: id,
                                            code: code.toString(),
                                            subcat_id: dataList[index].id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }));
                      } else {
                        return Center(
                          child: Text(
                            "No data available",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                    },
                  )),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
