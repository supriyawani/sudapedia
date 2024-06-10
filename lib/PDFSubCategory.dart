import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/PDFViewerFromUrl.dart';
import 'package:sudapedia/repository/PDFSubCategory_repo.dart';
import 'package:sudapedia/repository/Stats_repo.dart';

class PDFSubCategory extends StatefulWidget {
  String id, code, subcat_id, color_id, categoryName, color_code_id;

  PDFSubCategory({
    required this.id,
    required this.code,
    required this.subcat_id,
    required this.color_id,
    required this.categoryName,
    required this.color_code_id,
  });

  @override
  _PDFSubCategoryState createState() => _PDFSubCategoryState(
      id, code, subcat_id, color_id, categoryName, color_code_id);
}

class _PDFSubCategoryState extends State<PDFSubCategory> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //String userToken = "FTGHI2W8XS"; // Replace with actual user token
  String? userToken; // Replace with actual user token
  StreamController? _postsController;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //String id = "", code = "", subcat_id = "", color_id = "", categoryName = "", color_code_id = "";
  String id = "",
      code = "",
      subcat_id = "",
      color_id = "",
      categoryName = "",
      color_code_id = "";
  String pdf_id = "";
  bool isDownloaded = false;
  String downloadedFilePath = '';
  String downloadedFilePathforpdfview = '';
  Map<String, String> downloadedPDFs = {};
  _PDFSubCategoryState(String id, String code, String subcat_id,
      String color_id, String categoryName, String color_code_id) {
    this.id = id;
    this.code = code;
    this.subcat_id = subcat_id;
    this.color_id = color_id;
    this.categoryName = categoryName;
    this.color_code_id = color_code_id;
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
      color_code_id = prefs.getString('color_code_id')!;
    });
    //loadPosts();
    print("id:" + id);
    print("code:" + code);
    print("subcat_id:" + subcat_id);
    print("color_id:" + color_id);
    print("color_code_id:" + color_code_id);
  }

  Future<bool> isPDFDownloaded(String pdfId) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(pdfId)) {
      String? filePath = prefs.getString(pdfId);
      if (filePath != null && await File(filePath).exists()) {
        return true;
      }
    }
    return false;
  }

  Future<void> getToken() async {
    userToken = await DatabaseHelper().getToken();

    print("Token:" + userToken!);
    // _categoriesStream = categoryRepo.getCategoryStream(userToken.toString());
    setState(() {
      getCategoryName();
    });

    print("Token:" + userToken!);
  }

  // _CategoryDetailsState(this.id);

  loadPosts() async {
    var apiProvider = PDFSubCategory_repo();
    apiProvider
        .getPDFList(userToken.toString(), id.toString(), subcat_id.toString(),
            color_id.toString(), color_code_id.toString())
        .then((res) async {
      _postsController?.add(res);
      return res;
    });
  }

  void getCategoryName() async {
    PDFSubCategory_repo()
        .getColorDetailsTitle(userToken.toString(), id, subcat_id.toString(),
            color_id.toString(), color_code_id)
        .then((result) {
      if (result != null) {
        setState(() {
          print("result:" + result.toString());
          categoryName = result.toString();
          print("categoryName:" + categoryName.toString());
          loadPosts();
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
                  ),
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
                        return ListView.builder(
                          //physics: NeverScrollableScrollPhysics(),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: dataList.length,
                          itemBuilder: (context, index) {
                            return FutureBuilder<bool>(
                                future: isPDFDownloaded(
                                    dataList[index].id.toString()),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }

                                  bool isDownloaded = snapshot.data!;
                                  return GestureDetector(
                                      onTap: () async {
                                        if (isDownloaded) {
                                          print("ontap isDownloaded");
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          String filePath = prefs.getString(
                                              dataList[index].id.toString())!;
                                          //openPDF(filePath);
                                          await OpenFilex.open(filePath);
                                        } else {
                                          print("ontap");
                                          pdf_id =
                                              dataList[index].id.toString();
                                          print(Constant.url_pdf_path +
                                              dataList[index].pDFPath);
                                          pdfviewer(Constant.url_pdf_path +
                                              dataList[index].pDFPath);
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 10.sp, right: 10.sp),
                                        child: ClipRRect(
                                          //  borderRadius: BorderRadius.circular(20.sp),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: SvgPicture.asset(
                                                  "assets/pdf_field.svg",
                                                ),
                                              ),
                                              ListTile(
                                                contentPadding: EdgeInsets.only(
                                                    left: 15.sp,
                                                    right: 15.sp,
                                                    bottom: 5.sp,
                                                    top: 5.sp),
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                        child: Text(
                                                      dataList[index].pDFName ??
                                                          'No Name',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Color(
                                                            0xFFE97132), // Replace with your desired color
                                                      ),
                                                    )),
                                                    isDownloaded
                                                        ? IconButton(
                                                            icon: Icon(
                                                                Icons.share,
                                                                size: 18.sp,
                                                                color: Colors
                                                                    .blue),
                                                            onPressed:
                                                                () async {
                                                              final prefs =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              String filePath =
                                                                  prefs.getString(
                                                                      dataList[
                                                                              index]
                                                                          .id
                                                                          .toString())!;
                                                              shareFile(
                                                                  filePath);
                                                            },
                                                          )
                                                        : IconButton(
                                                            icon: Icon(
                                                                Icons
                                                                    .download_for_offline_outlined,
                                                                size: 18.sp,
                                                                color: Colors
                                                                    .blue),
                                                            onPressed:
                                                                () async {
                                                              pdf_id = dataList[
                                                                      index]
                                                                  .id
                                                                  .toString();
                                                              await downloadPDF(Constant
                                                                      .url_pdf_path +
                                                                  dataList[
                                                                          index]
                                                                      .pDFPath);
                                                            },
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                                });
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
                  /*Expanded(
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
                        //} else if (snapshot.hasData &&(snapshot.data as List).isEmpty) {
                        print("Data: ${snapshot.data}");

                        List<dynamic> dataList = snapshot.data;
                        return ListView.builder(
                          //physics: NeverScrollableScrollPhysics(),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: dataList.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin:
                                  EdgeInsets.only(left: 10.sp, right: 10.sp),
                              child: ClipRRect(
                                //  borderRadius: BorderRadius.circular(20.sp),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: SvgPicture.asset(
                                        "assets/pdf_field.svg",
                                        // fit: BoxFit.cover,
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.only(
                                          left: 15.sp,
                                          right: 15.sp,
                                          bottom: 5.sp,
                                          top: 5.sp),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                              child: Text(
                                            dataList[index].pDFName ??
                                                'No Name',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Color(
                                                  0xFFE97132), // Replace with your desired color
                                            ),
                                          )),
                                          IconButton(
                                            icon: Icon(
                                              Icons
                                                  .download_for_offline_outlined,
                                              size: 20.sp,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              //  openPdfFromUrl(Constant.url + dataList[index].pDFPath);
                                              // launchPDF((Constant.url_pdf_path + dataList[index].pDFPath));
                                              downloadPDF(
                                                  (Constant.url_pdf_path +
                                                      dataList[index].pDFPath));
                                              // Handle the download action
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                  )),*/
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  /*Color getColor(String code) {
    switch (code) {
      case 'A':
        return Color(0xFFBABDFF);
      case 'B':
        return Color(0xFFFFDFBA);
      case 'C':
        return Color(0xFFD6FFF0);
      case 'D':
        return Color(0xFFE4FFC1);
      case 'E':
        return Color(0xFFBEDCFF);
      case 'F':
        return Color(0xFFD9FCFF);
      case 'G':
        return Color(0xFFFFCDEB);
      case 'H':
        return Color(0xFFE1BAFF);
      case 'I':
        return Color(0xFFFFB2B2);
      case 'J':
        return Color(0xFFFF9BBF);
      case 'K':
        return Color(0xFFFF9BBF);

      default:
        return Color(0xFFFFDFBA); // fallback image
    }
  }*/

  /* void launchPDF(String pdfUrl) async {
    if (await canLaunch(pdfUrl)) {
      await launch(pdfUrl);
    } else {
      throw 'Could not launch $pdfUrl';
    }
  }

  void openPdfFromUrl(String url) {
    debugPrint('opening PDF url = $url');
    var googleDocsUrl =
        'https://docs.google.com/gview?embedded=true&url=${Uri.encodeQueryComponent(url)}';
    debugPrint('opening Google docs with PDF url = $googleDocsUrl');
    final Uri uri = Uri.parse(googleDocsUrl);
    launchUrl(uri);
  }*/

  /*Future<void> downloadPDF(String url) async {
    try {
      // Create a Dio instance
      Dio dio = Dio();

      // Extract the file name from the URL
      String fileName = url.split('/').last;

      // Get the application directory (documents directory)
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // Define the full file path
      String fullPath = '$appDocPath/$fileName';

      // Download the file
      await dio.download(url, fullPath);

      print('fileName PDF downloaded to: $fullPath');
      Fluttertoast.showToast(
        msg: "$fileName is download",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }*/
  Future<void> pdfviewer(String url) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PDFViewerFromUrl(
              pdfUrl: url,
            )));
  }

  Future<void> downloadPDF(String url) async {
    try {
      // Create a Dio instance
      Dio dio = Dio();

      // Extract the file name from the URL
      String fileName = url.split('/').last;

      // Get the application directory (documents directory)
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // Define the full file path
      String fullPath = '$appDocPath/$fileName';

      // Download the file
      await dio.download(url, fullPath);

      print('fileName PDF downloaded to: $fullPath');
      Fluttertoast.showToast(
        msg: "$fileName is downloaded",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      final dbHelper = DatabaseHelper();

      // Insert an employee ID

      // Retrieve the employee ID
      final employeeID = await dbHelper.getEmployeeID();
      print("Retrieved employeeID: $employeeID");

      // Insert a user token
      print("Retrieved userToken: $userToken");
      Stats_repo()
          .fetchCategoryData(userToken.toString(), id, pdf_id, employeeID!);

      // Save the downloaded PDF info in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(pdf_id, fullPath);

      // Update the local map and state
      setState(() {
        downloadedPDFs[pdf_id] = fullPath;
      });
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }

  void shareFile(String filePath) {
    Share.shareFiles([filePath], text: 'Check out this PDF!');
  }
}

/*class PDFViewerFromUrl extends StatelessWidget {
  final String url;

  PDFViewerFromUrl({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: url,
      ),
    );
  }
}*/
