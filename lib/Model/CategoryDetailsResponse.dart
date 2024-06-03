class PdfCategoryResponse {
  String? success;
  String? failure;
  String? msg;
  String? categoryName;
  List<PdfArr>? pdfArr;
  List<SubcategoriesArr>? subcategoriesArr;

  PdfCategoryResponse(
      {this.success,
      this.failure,
      this.msg,
      this.categoryName,
      this.pdfArr,
      this.subcategoriesArr});

  PdfCategoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    failure = json['Failure'];
    msg = json['msg'];
    categoryName = json['CategoryName'];
    if (json['pdf_arr'] != null) {
      pdfArr = <PdfArr>[];
      json['pdf_arr'].forEach((v) {
        pdfArr!.add(PdfArr.fromJson(v));
      });
    }
    if (json['Subcategories_arr'] != null) {
      subcategoriesArr = <SubcategoriesArr>[];
      json['Subcategories_arr'].forEach((v) {
        subcategoriesArr!.add(SubcategoriesArr.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Success'] = success;
    data['Failure'] = failure;
    data['msg'] = msg;
    data['CategoryName'] = categoryName;
    if (pdfArr != null) {
      data['pdf_arr'] = pdfArr!.map((v) => v.toJson()).toList();
    }
    if (subcategoriesArr != null) {
      data['Subcategories_arr'] =
          subcategoriesArr!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PdfArr {
  String? id;
  String? pDFName;
  String? pDFPath;

  PdfArr({this.id, this.pDFName, this.pDFPath});

  PdfArr.fromJson(Map<String, dynamic> json) {
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

class SubcategoriesArr {
  final String id;
  final String subCategoryName;

  SubcategoriesArr({
    required this.id,
    required this.subCategoryName,
  });

  factory SubcategoriesArr.fromJson(Map<String, dynamic> json) {
    return SubcategoriesArr(
      id: json['Id'] ?? '',
      subCategoryName: json['SubCategoryName'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = this.id;
    data['SubCategoryName'] = this.subCategoryName;
    return data;
  }
}
