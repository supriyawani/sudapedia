import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:sudapedia/Common/BackgroundWithLogo.dart';
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
    //String? groupId = await DatabaseHelper().getGroupID();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? groupId = prefs.getString(Constant.groupID);
    var apiProvider = PDFSubCategory_repo();
    apiProvider
        .getPDFList(userToken.toString(), id.toString(), subcat_id.toString(),
            color_id.toString(), color_code_id.toString(), groupId.toString())
        .then((res) async {
      _postsController?.add(res);
      return res;
    });
  }

  void getCategoryName() async {
    /* PDFSubCategory_repo()
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
    });*/
    try {
      // String? groupId = await DatabaseHelper().getGroupID();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? groupId = prefs.getString(Constant.groupID);
      String? result = await PDFSubCategory_repo().getColorDetailsTitle(
          userToken.toString(),
          // widget.id,
          id.toString(),
          subcat_id.toString(),
          color_id.toString(),
          color_code_id,
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
          Constant().initMixpanel("PDF for " + categoryName);
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

                                  //  bool isDownloaded = snapshot.data!;
                                  return Container(
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
                                                Expanded(
                                                    child: Text(
                                                  dataList[index].pDFName ??
                                                      'No Name',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors
                                                        .black, // Replace with your desired color
                                                  ),
                                                )),
                                                GestureDetector(
                                                  child: Container(
                                                      margin:
                                                          EdgeInsets.all(5.sp),
                                                      child: Text(
                                                        "show",
                                                        style: TextStyle(
                                                            color: Colors.blue),
                                                      )),
                                                  onTap: () {
                                                    pdf_id = dataList[index]
                                                        .id
                                                        .toString();
                                                    String pdfurl = Constant
                                                            .url_pdf_path +
                                                        dataList[index].pDFPath;
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                PDFViewerFromUrl(
                                                                  pdfUrl:
                                                                      pdfurl,
                                                                )));
                                                  },
                                                ),
                                                Container(
                                                    margin:
                                                        EdgeInsets.all(5.sp),
                                                    child: IconButton(
                                                        icon: Icon(Icons.share,
                                                            size: 18.sp,
                                                            color: Colors.blue),
                                                        onPressed: () async {
                                                          if (downloadedPDFs
                                                              .containsKey(dataList[
                                                                      index]
                                                                  .id
                                                                  .toString())) {
                                                            shareFile(downloadedPDFs[
                                                                dataList[index]
                                                                    .id
                                                                    .toString()]!);
                                                          } else {
                                                            pdf_id =
                                                                dataList[index]
                                                                    .id
                                                                    .toString();
                                                            await downloadPDF(Constant
                                                                    .url_pdf_path +
                                                                dataList[index]
                                                                    .pDFPath);
                                                            shareFile(downloadedPDFs[
                                                                dataList[index]
                                                                    .id
                                                                    .toString()]!);
                                                          }
                                                        })),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
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

  String? FileName;

  Future<void> downloadPDF(String url) async {
    try {
      Dio dio = Dio();
      String fileName = url.split('/').last;
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String fullPath = '$appDocPath/$fileName';
      await dio.download(url, fullPath);
      print(fullPath.toString());
      setState(() {
        downloadedPDFs[pdf_id] = fullPath;
        FileName = fileName;
      });

      final dbHelper = DatabaseHelper();
      final employeeID = await dbHelper.getEmployeeID();
      Stats_repo()
          .fetchCategoryData(userToken.toString(), id, pdf_id, employeeID!);
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }

  Future<void> pdfviewer(String url) async {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PDFViewerFromUrl(
              pdfUrl: url,
            )));
  }

  void shareFile(String filePath) {
    // Share.shareFiles([filePath], text: 'Check out this PDF!');
    if (filePath != null) {
      print(filePath.toString());
      Share.shareFiles([filePath], text: 'Check out this PDF!');
      Constant.logpdf(
        pdfname: "Shared " + FileName.toString(),
      );
      Constant().initMixpanel("" + FileName.toString() + " " + "Shared");
    } else {
      print("File path is null. Cannot share the file.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please download the pdf')),
      );
      //  Constant.displayToast("Please download the pdf");
    }
  }
}
