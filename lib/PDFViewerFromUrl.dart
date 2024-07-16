import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

class PDFViewerFromUrl extends StatefulWidget {
  final String pdfUrl;

  PDFViewerFromUrl({
    required this.pdfUrl,
  });

  @override
  _PDFViewerFromUrlState createState() => _PDFViewerFromUrlState();
}

class _PDFViewerFromUrlState extends State<PDFViewerFromUrl> {
  String downloadablePdfUrl = "";
  bool isLoading = true;
  String? localPath;
  PdfViewerController pdfController = PdfViewerController();

  @override
  void initState() {
    super.initState();
    debugPrint("PDF URL: ${widget.pdfUrl}");
    downloadablePdfUrl = widget.pdfUrl.replaceAll(" ", "%20");
    //widget.pdfUrl.replaceAll(" ", "%20");
    debugPrint("downloadablePdfUrl: $downloadablePdfUrl");
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
      String fileName = downloadablePdfUrl.split('/').last;

      // Define the full file path
      String fullPath = '$appDocPath/$fileName'.replaceAll("%20", "_");
      debugPrint("Full Path: $fullPath");

      // Download the file
      await dio.download(downloadablePdfUrl, fullPath);

      setState(() {
        localPath = fullPath;
        debugPrint("Local Path: $localPath");

        isLoading = false;
      });
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : localPath != null
              ? PdfDocumentViewBuilder.asset(localPath!,
                  builder: (context, document) {
                  debugPrint(localPath);
                  return PdfViewer.asset(
                    localPath!,
                    controller: pdfController,
                  );
                })
              : Center(child: Text('Error loading PDF')),
    );
  }
}
