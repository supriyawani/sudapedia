import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/BackgroundWithLogo.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Model/SubCategoryButtonResponse.dart';
import 'package:sudapedia/SubCategoryButtonDetails.dart';
import 'package:sudapedia/repository/SubCategoryButton_repo.dart';

class SubCategoryButtons extends StatefulWidget {
  String id, code, subcat_id, categoryName;

  SubCategoryButtons(
      {required this.id,
      required this.code,
      required this.subcat_id,
      required this.categoryName});

  @override
  _SubCategoryButtonsState createState() =>
      _SubCategoryButtonsState(id, code, subcat_id, categoryName);
}

class _SubCategoryButtonsState extends State<SubCategoryButtons> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //String userToken = "FTGHI2W8XS"; // Replace with actual user token
  String? userToken; // Replace with actual user token
  StreamController? _postsController;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String id = "", code = "", subcat_id = "", categoryName = "";
  String? subcategoryName = "";
  Stream<List<ColorCode_arr>> _categoriesStream = Stream.value([]);

  _SubCategoryButtonsState(
      String id, String code, String subcat_id, String categoryName) {
    this.id = id;
    this.code = code;
    this.subcat_id = subcat_id;
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
      categoryName = prefs.getString('categoryName')!;
    });
    print("id:" + id);
    print("code:" + code);
    print("subcat_id:" + subcat_id);
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
    var apiProvider = SubCategoryButton_repo();
    String? groupId = await DatabaseHelper().getGroupID();
    apiProvider
        .getSubcategorybuttonList(
            userToken.toString(), id.toString(), subcat_id, groupId.toString())
        .then((res) async {
      _postsController?.add(res);
      return res;
    });
  }

  void getCategoryName() async {
    /*SubCategoryButton_repo()
        .getsubCategoryName(
            userToken.toString(), id.toString(), subcat_id.toString())
        .then((result) {
      if (result != null) {
        setState(() {
          print("result:" + result.toString());
          subcategoryName = result.toString();
          print("categoryName:" + subcategoryName.toString());
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
      String? groupId = await DatabaseHelper().getGroupID();
      String? result = await SubCategoryButton_repo().getsubCategoryName(
          userToken.toString(),
          widget.id,
          subcat_id.toString(),
          groupId.toString());
      if (result != null) {
        setState(() {
          print("result:" + result.toString());
          categoryName = result.toString();
          print("categoryName:" + categoryName.toString());
          loadPosts();
        });
      }
    } catch (e) {
      print("Exception occurred: $e");
      Constant.navigatetoSendotp(context);
    }
  }

  final String bgcolor = "R254/G204/B0";
  @override
  Widget build(BuildContext context) {
    return /*GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => SessionTimeoutManager.resetLogoutTimer(context),
        child: WillPopScope(onWillPop: () async {
          SessionTimeoutManager.resetLogoutTimer(context);
          return true;
        }, child:*/
        Sizer(builder: (context, orientation, deviceType) {
      return Scaffold(
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
                            subcategoryName.toString(),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),*/
                  CustomAppBar(categoryName: categoryName, code: code),
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
                              child: Card(
                                  child: Container(
                                //color: parseColor(dataList[index].code),
                                decoration: BoxDecoration(
                                  color: parseColor1(dataList[index].code),
                                  // color: parseColor1(bgcolor),
                                  border: Border.all(
                                      color: Colors.white, width: 3.0),
                                  borderRadius: BorderRadius.circular(15.0),
                                  boxShadow: [
                                    BoxShadow(
                                      //   color: Color(0xFF18174E)
                                      color: Colors.white38.withOpacity(
                                          0.25), // Opacity adjusted based on Figma value
                                      offset: Offset(0, -3),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Color(0xFF221750).withOpacity(
                                          0.18), // Opacity adjusted based on Figma value
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
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
                                                -2), // Adjust offset as needed
                                            blurRadius: 4,
                                          ),
                                        ],*/
                                child: Center(
                                    child:
                                        Text(dataList[index].title ?? 'No Name',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                              color: txtcolor(dataList[index]
                                                  .textcolor
                                                  .toString()),
                                              /*dataList[index].textcolor.toString()*/
                                              // Replace with your desired color
                                            ))),
                              )),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SubCategoryButtonDetails(
                                      categoryName: subcategoryName.toString(),
                                      id: id,
                                      code: code.toString(),
                                      subcat_id: subcat_id.toString(),
                                      color_id: dataList[index].id,
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
    });
  }

  Color txtcolor(String txtcolor) {
    Color value = Colors.black;
    if (txtcolor.contains('black')) {
      value = Colors.black;
    } else {
      value = Colors.white;
    }
    return value;
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

  Color parseColor1(String colorString) {
    // Remove "R", "G", "B" and split by '/'
    List<String> parts = colorString
        .replaceAll('R', '')
        .replaceAll('G', '')
        .replaceAll('B', '')
        .split('/');
    if (parts.length != 3) {
      throw FormatException("Invalid color string: $colorString");
    }

    int r = int.parse(parts[0]);
    int g = int.parse(parts[1]);
    int b = int.parse(parts[2]);

    // Return the color with full opacity
    return Color.fromARGB(255, r, g, b);
  }
}
