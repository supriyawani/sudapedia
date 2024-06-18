import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/Constant.dart';

class BackgroundWithLogo extends StatelessWidget {
  final String code;

  const BackgroundWithLogo({
    Key? key,
    required this.code,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
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
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final String categoryName;
  final String code;

  const CustomAppBar({
    Key? key,
    required this.categoryName,
    required this.code,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return Column(children: [
        Container(
          color: Constant.getColor(code.toString()),
          width: double.infinity, // Span the full width
          child: Stack(
            children: [
              Image.asset(
                'assets/appbar_logo.png',
                fit: BoxFit.contain, // Adjust fit as needed
                width: double.infinity,
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                    margin: EdgeInsets.only(top: 38.sp, left: 5.sp),
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          size: 20.sp, color: Colors.black),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 5.sp, bottom: 5.sp, left: 15.sp),
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
        ),
      ]);
    });
  }
}
