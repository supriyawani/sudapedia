import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:open_file/open_file.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/Constant.dart';
import 'package:sudapedia/Database/DatabaseHelper.dart';
import 'package:sudapedia/PDFViewerFromUrl.dart';
import 'package:sudapedia/repository/CategoryDetails_repo.dart';
import 'package:sudapedia/repository/Stats_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class CategoryDetails extends StatefulWidget {
  String id, code;

  CategoryDetails({required this.id, required this.code});
  @override
  _CategoryDetailsState createState() => _CategoryDetailsState(id, code);
}

class _CategoryDetailsState extends State<CategoryDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  //String userToken = "FTGHI2W8XS"; // Replace with actual user token
  String? userToken; // Replace with actual user token
  StreamController? _postsController;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String id = "", code = "";
  String? categoryName = "";
  String pdf_id = "";
  bool isDownloaded = false;
  String downloadedFilePath = '';
  Map<String, String> downloadedPDFs = {};
  _CategoryDetailsState(String id, String code) {
    this.id = id;
    this.code = code;
  }
  @override
  initState() {
    super.initState();
    _postsController = StreamController();
    getToken();

    _prefs.then((SharedPreferences prefs) async {
      id = prefs.getString('id')!;
      code = prefs.getString('code')!;

      // Load downloaded PDFs information
      final keys = prefs.getKeys();
      for (String key in keys) {
        if (key.startsWith('pdf_')) {
          // Ensure it matches the expected key pattern
          downloadedPDFs[key] = prefs.getString(key)!;
        }
      }

      setState(() {}); // Update the UI
    });
  }

  Future<bool> isPDFDownloaded(String pdfId) async {
    /* final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(pdfId);*/
    /*final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(pdfId)) {
      String? filePath = prefs.getString(pdfId);
      if (filePath != null) {
        return File(filePath).existsSync();
      }
    }
    return false;*/

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
    userToken = (await DatabaseHelper().getToken())!;
    getCategoryName();
    print("Token:" + userToken!);
  }
  // _CategoryDetailsState(this.id);

  loadPosts() async {
    var apiProvider = CategoryDetails_repo();
    apiProvider
        .getPDFList(userToken.toString(), id.toString())
        .then((res) async {
      _postsController?.add(res);
      return res;
    });
  }

  void getCategoryName() async {
    CategoryDetails_repo()
        .getCategoryName(userToken.toString(), id.toString())
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
                                          String pdfurl =
                                              Constant.url_pdf_path +
                                                  dataList[index].pDFPath;
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PDFViewerFromUrl(
                                                        pdfUrl: pdfurl,
                                                      )));
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
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  /* void openPDF(String filePath) {
    OpenFile.open(filePath).then((result) {
      */ /*if (result.type != ResultType.done) {
        Fluttertoast.showToast(
          msg: "Failed to open the file. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }*/ /*
    });
  }*/

  void launchPDF(String pdfUrl) async {
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
