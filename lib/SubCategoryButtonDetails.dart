import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/BackgroundWithLogo.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Model/SubCategoryButtonResponse.dart';
import 'package:sudapedia/PDFSubCategory.dart';
import 'package:sudapedia/SessionTimeoutManager.dart';
import 'package:sudapedia/repository/SubCategoryButtonsDetails_repo.dart';

class SubCategoryButtonDetails extends StatefulWidget {
  String id, code, subcat_id, color_id, categoryName;

  SubCategoryButtonDetails({
    required this.id,
    required this.code,
    required this.subcat_id,
    required this.color_id,
    required this.categoryName,
  });

  @override
  _SubCategoryButtonDetailsState createState() =>
      _SubCategoryButtonDetailsState(
          id, code, subcat_id, color_id, categoryName);
}

class _SubCategoryButtonDetailsState extends State<SubCategoryButtonDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //String userToken = "FTGHI2W8XS"; // Replace with actual user token
  String? userToken; // Replace with actual user token
  StreamController? _postsController;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String id = "", code = "", subcat_id = "", color_id = "", categoryName = "";
  String? colorTitle = "";
  Stream<List<ColorCode_arr>> _categoriesStream = Stream.value([]);

  _SubCategoryButtonDetailsState(String id, String code, String subcat_id,
      String color_id, String categoryName) {
    this.id = id;
    this.code = code;
    this.subcat_id = subcat_id;
    this.color_id = color_id;
    this.categoryName = categoryName;
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
      subcat_id = prefs.getString('subcat_id')!;
      color_id = prefs.getString('color_id')!;
      categoryName = prefs.getString('categoryName')!;
    });
    print("id:" + id);
    print("code:" + code);
    print("subcat_id:" + subcat_id);
    print("color_id:" + color_id);
    print("categoryName:" + categoryName);
  }

  Future<void> getToken() async {
    // userToken = (await DatabaseHelper().getToken())!;
    userToken = await DatabaseHelper().getToken1(context);
    //userToken = "953Qi5k8I3T0voK";
    print("Token:" + userToken!);
    // _categoriesStream = categoryRepo.getCategoryStream(userToken.toString());
    setState(() {
      getCategoryName();
    });
    print("Token:" + userToken!);
  }

  // _CategoryDetailsState(this.id);

  loadPosts() async {
    var apiProvider = SubCategoryButtonDetails_repo();
    apiProvider
        .getSubcategorybuttonDetailsList(
            userToken.toString(), id.toString(), subcat_id, color_id)
        .then((res) async {
      _postsController?.add(res);
      return res;
    });
  }

  void getCategoryName() async {
    /*SubCategoryButtonDetails_repo()
        .getcolorTitle(
            userToken.toString(), id.toString(), subcat_id.toString(), color_id)
        .then((result) {
      if (result != null) {
        setState(() {
          print("result:" + result.toString());
          colorTitle = result.toString();
          print("categoryName:" + colorTitle.toString());
          loadPosts();
        });

        // saveData(result);
      } else {
        setState(() {
          // Constant.displayToast("please enter valid credentials!");
        });
      }
    });*/
    try {
      String? result = await SubCategoryButtonDetails_repo().getcolorTitle(
          userToken.toString(), widget.id, subcat_id.toString(), color_id);
      if (result != null) {
        setState(() {
          print("result:" + result.toString());
          colorTitle = result.toString();
          print("categoryName:" + colorTitle.toString());
          loadPosts();
        });
      }
    } catch (e) {
      print("Exception occurred: $e");
      Constant.navigatetoSendotp(context);
    }
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
            body: Stack(
              children: <Widget>[
                /*  Container(
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
                BackgroundWithLogo(code: code),
                Container(
                  child: Column(
                    children: [
                      /*   Container(
                        color: Constant.getColor(code.toString()),
                        width: double.infinity, // Span the full width
                        child: Image.asset(
                          'assets/appbar_logo.png',
                          fit: BoxFit.contain, // Adjust fit as needed
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5.sp, bottom: 5.sp),
                        color: Constant.getColor(code.toString()),
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            categoryName.toString(),
                            style: TextStyle(
                              fontSize: 18.sp,
                              //fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),*/
                      CustomAppBar(categoryName: categoryName, code: code),
                      Container(
                        padding: EdgeInsets.only(top: 5.sp, bottom: 2.sp),
                        // margin: EdgeInsets.all(15.sp),
                        margin: EdgeInsets.only(
                            left: 15.sp,
                            right: 15.sp,
                            bottom: 5.sp,
                            top: 10.sp),
                        //  color: getColor(code.toString()),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF221750).withOpacity(
                                  0.05), // Opacity adjusted based on Figma value
                              offset: Offset(0, 0),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(children: [
                          Positioned.fill(
                            child: SvgPicture.asset(
                              'assets/title_subcategoryDetails_Button.svg',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Center(
                              child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(15.sp),
                            child: Text(
                              colorTitle.toString(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                //fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ))
                        ]),
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
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            print("Data: ${snapshot.data}");
                            List<dynamic> dataList = snapshot.data;
                            return GridView.builder(
                              padding: EdgeInsets.all(15.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 3 / 2,
                              ),
                              itemCount: dataList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  child: Container(
                                      margin: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0xFF221750).withOpacity(
                                                0.09), // Opacity adjusted based on Figma value
                                            offset: Offset(0, 0),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      /* child: InnerShadow(
                                          shadows: [
                                            Shadow(
                                              color: Color(0xFF18174E)
                                                  .withOpacity(
                                                      0.25), // Inner shadow
                                              offset: Offset(0,
                                                  2), // Adjust offset as needed
                                              blurRadius: 4,
                                            ),
                                          ],*/
                                      child: Stack(children: [
                                        Positioned.fill(
                                          child: SvgPicture.asset(
                                            'assets/subcategoryDetails_Button.svg',
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(
                                                left: 5.sp,
                                                right: 5.sp,
                                                bottom: 5.sp),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Text(
                                                  dataList[index]
                                                      .title
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 15.sp
                                                      // Optional: add background color for better readability
                                                      ),
                                                  textAlign: TextAlign
                                                      .center, // Center the text
                                                ),
                                              ),
                                            )),
                                      ])
                                      //onTap: onTap,
                                      ),
                                  onTap: () {
                                    print("id:" +
                                        id +
                                        "subcat_id:" +
                                        subcat_id +
                                        "color_id:" +
                                        color_id +
                                        "color_code_id:" +
                                        dataList[index].id);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PDFSubCategory(
                                          id: id,
                                          code: code.toString(),
                                          subcat_id: subcat_id.toString(),
                                          color_id: color_id,
                                          categoryName: categoryName.toString(),
                                          color_code_id: dataList[index].id,
                                        ),
                                      ),
                                    );
                                  },
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
                      )),
                    ],
                  ),
                )
              ],
            ),
          );
        })));
  }

  Color parseColor(String colorString) {
    // Trim any whitespace from the color string
    colorString = colorString.trim();

    // Ensure the string is a valid 6-character hexadecimal
    if (colorString.length != 6 ||
        !RegExp(r'^[0-9A-Fa-f]{6}$').hasMatch(colorString)) {
      throw FormatException("Invalid color string: $colorString");
    }

    // Prefix with 'FF' to make it ARGB
    String valueString = 'FF' + colorString;

    // Parse the ARGB value
    int value = int.parse(valueString, radix: 16);
    return Color(value);
  }
}
