import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/CategoryComparison.dart';
import 'package:sudapedia/CategoryDetails.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/Model/CategoriesResponse.dart';
import 'package:sudapedia/SubCategory.dart';
import 'package:sudapedia/SubCategoryButtons.dart';
import 'package:sudapedia/repository/Category_repo.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    //_startLogoutTimer();
    //  _categoriesStream = categoryRepo.getCategoryStream(userToken!);
  }

  @override
  void dispose() {
    //_logoutTimer?.cancel();
    super.dispose();
  }

  /* void _startLogoutTimer() async {
    const logoutDuration = Duration(minutes: 30);
    if (!(await SessionManager.isUserLoggedIn())) {
      return;
    }

    _logoutTimer = Timer(logoutDuration, _logoutUser);
  }

  void _logoutUser() async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {
      'employee_id': employeeId,
      'UserToken': userToken,
      'apiKey': "8c961641025d48b7b89d475054d656da"
    };

    var response = await http.post(
        Uri.parse("https://sudapedia.sudarshan.com/Admin/web-api/logout.php"),
        headers: headers,
        body: body);
    print(response.body.toString());
    print(response.body);
    if (response.body.contains("Logout Successfully !!")) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['msg'] == 'Logout Successfully !!') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['msg'])),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SendOTP()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${jsonResponse['msg']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server')),
      );
    }
  }*/

  Future<void> getToken() async {
    userToken = await DatabaseHelper().getToken1(context);
    //userToken = "1E5O3tCJuz03bib";
    print("Token:" + userToken!);
    // _categoriesStream = categoryRepo.getCategoryStream(userToken.toString());
    setState(() {
      _categoriesStream = categoryRepo.getCategoryStream(userToken.toString());
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
                    padding: EdgeInsets.only(
                        top:
                            150.0), // Adjust top padding to avoid overlap with the image
                    child: GridView.builder(
                      padding: EdgeInsets.all(15.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            child: /*return*/ CategoryItem(
                              category: categories[index],
                              /*onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryDetails(
                                      id: categories[index].id.toString()),
                                ),
                              );
                            }*/
                            ),
                            onTap: () {
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
          ],
        ),
      );
    });
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
    return Container(
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              getSvgImageAssetPath(category.code.toString()),
              fit: BoxFit.fill,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.sp, right: 5.sp),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  category.categoryName.toString(),
                  style: TextStyle(fontSize: 12.sp
                      // Optional: add background color for better readability
                      ),
                  textAlign: TextAlign.center, // Center the text
                ),
              ),
            ),
            //onTap: onTap,
          )
        ],
      ),
    );
  }

  String getSvgImageAssetPath(String code) {
    switch (code) {
      case 'A':
        return 'assets/applications.svg';
      case 'B':
        return 'assets/brochure.svg';
      case 'C':
        return 'assets/presentation.svg';
      case 'D':
        return 'assets/interfamily_comparison.svg';
      case 'E':
        return 'assets/RAL.svg';
      case 'F':
        return 'assets/pantone.svg';
      case 'G':
        return 'assets/regulatory_compilance.svg';
      case 'H':
        return 'assets/master_list.svg';
      case 'I':
        return 'assets/test_methode.svg';
      case 'J':
        return 'assets/product_withdrawal.svg';
      case 'K':
        return 'assets/applications.svg';
      case 'L':
        return 'assets/brochure.svg';
      default:
        return 'assets/default.png'; // fallback image
    }
  }
}
