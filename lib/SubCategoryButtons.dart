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
  String? Category;
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
    Category = categoryName;
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
    // String? groupId = await DatabaseHelper().getGroupID();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? groupId = prefs.getString(Constant.groupID);
    print("groupID:" + groupId.toString());
    apiProvider
        .getSubcategorybuttonList(
            userToken.toString(), id.toString(), subcat_id, groupId.toString())
        .then((res) async {
      _postsController?.add(res);
      return res;
    });
  }

  void getCategoryName() async {
    try {
      //String? groupId = await DatabaseHelper().getGroupID();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? groupId = prefs.getString(Constant.groupID);
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
          Constant.logCategoryItemTap(
            categoryId: widget.id,
            categoryName: categoryName.toString(),
          );
          //   Constant().initMixpanel(Category.toString() + " " + categoryName.toString());
          Constant().initMixpanel(categoryName.toString());
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
    return Sizer(builder: (context, orientation, deviceType) {
      return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            BackgroundWithLogo(code: code),
            Container(
              child: Column(
                children: [
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

                                child: Center(
                                    child:
                                        Text(dataList[index].title ?? 'No Name',
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                              color: txtcolor(dataList[index]
                                                  .textcolor
                                                  .toString()),
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
