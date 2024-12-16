import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import 'Common/Constant.dart';

class PDFViewerFromUrl extends StatefulWidget {
  final String pdfUrl;

  PDFViewerFromUrl({
    required this.pdfUrl,
  });

  @override
  _PDFViewerFromUrlState createState() => _PDFViewerFromUrlState();
}

class _PDFViewerFromUrlState extends State<PDFViewerFromUrl> {
  bool isLoading = true;
  String? localPath;
  // PdfViewerController pdfController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    downloadAndLoadPdf();
  }

  Future<void> downloadAndLoadPdf() async {
    try {
      // Create a Dio instance
      Dio dio = Dio();

      // Get the application directory (documents directory)
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // Extract the file name from the URL
      String fileName = widget.pdfUrl.split('/').last;

      // Define the full file path
      String fullPath = '$appDocPath/$fileName';

      // Download the file
      await dio.download(widget.pdfUrl, fullPath);

      setState(() {
        localPath = fullPath;
        isLoading = false;
      });
      Constant.logpdf(
        pdfname: fileName,
      );
      Constant().initMixpanel("" + fileName + "PDF viewed");
    } catch (e) {
      print('Error downloading PDF: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
/*<<<<<<< HEAD
      */ /* appBar: AppBar(
        title: Text('PDF Viewer'),
      ),*/ /*
=======
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        // actions: [
        //   TextButton(
        //       onPressed: () async {
        //         await pdfController.zoomUp();
        //       },
        //       child: Text("Zomm"))
        // ],
      ),
>>>>>>> c777c68 (ios build done)*/
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : /*localPath != null
              ? PdfDocumentViewBuilder.asset(localPath!,
                  builder: (context, document) {
                  return PdfViewer.asset(
                    localPath!,
                    controller: pdfController,
                  );
                })*/

            PDFView(
                filePath: localPath,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: false,
                pageFling: false,
                fitPolicy: FitPolicy.BOTH,
                onRender: (pages) {
                  setState(() {
                    isLoading = false;
                  });
                },
                onError: (error) {
                  print(error.toString());
                },
                onPageError: (page, error) {
                  print('$page: ${error.toString()}');
                },
              )
        // : Center(child: Text('Error loading PDF')),
        );
  }
}
