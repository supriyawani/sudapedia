import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/HomeScreen.dart';

class Pigments extends StatefulWidget {
  @override
  _PigmentsState createState() => _PigmentsState();
}

class _PigmentsState extends State<Pigments> {
  final _formKey = GlobalKey<FormState>();

  var isLoading = false;

  bool _isMounted = false;
  // String? Token;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
    // getToken();
    // print("Tocken:" + Token!);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();

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
                  image: AssetImage(
                    "assets/background_image.png",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(20.sp),
                      child: SvgPicture.asset(
                        "assets/pigments.svg",
                      ),
                      //  fit: BoxFit.fill,
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    }),
              ],
            )
          ]));
    });
  }

  buildColumn() {
    return Container(child: Text(""));
  }
}
