class PDFSubCategoryResponse {
  String? success;
  String? failure;
  String? msg;
  String? colorDetailsTitle;
  List<PdfArrforSubCategory>? pdfArr;

  PDFSubCategoryResponse(
      {this.success,
      this.failure,
      this.msg,
      this.colorDetailsTitle,
      this.pdfArr});

  PDFSubCategoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    failure = json['Failure'];
    msg = json['msg'];
    colorDetailsTitle = json['Color Details Title'];
    if (json['pdf_arr'] != null) {
      pdfArr = <PdfArrforSubCategory>[];
      json['pdf_arr'].forEach((v) {
        pdfArr!.add(PdfArrforSubCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Success'] = success;
    data['Failure'] = failure;
    data['msg'] = msg;
    data['Color Details Title'] = colorDetailsTitle;
    if (pdfArr != null) {
      data['pdf_arr'] = pdfArr!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class PdfArrforSubCategory {
  String? id;
  String? pDFName;
  String? pDFPath;

  PdfArrforSubCategory({this.id, this.pDFName, this.pDFPath});

  PdfArrforSubCategory.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    pDFName = json['PDFName'];
    pDFPath = json['PDFPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = this.id;
    data['PDFName'] = this.pDFName;
    data['PDFPath'] = this.pDFPath;
    return data;
  }
}
