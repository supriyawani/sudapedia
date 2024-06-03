class CategoriesResponse {
  String? id;
  String? categoryName;
  String? code;
  String? flag;
  String? is_comparisons;

  CategoriesResponse(
      {required this.id,
      required this.categoryName,
      required this.code,
      required this.is_comparisons,
      required this.flag});

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      id: json['Id'],
      categoryName: json['CategoryName'],
      code: json['code'],
      is_comparisons: json['is_comparisons'],
      flag: json['flag'].toString(),
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['CategoryName'] = this.categoryName;
    data['code'] = this.code;
    data['is_comparisons'] = this.is_comparisons;
    data['flag'] = this.flag;
    return data;
  }
}
