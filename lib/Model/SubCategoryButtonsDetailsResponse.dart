class SubCategoryButtonsDetailsResponse {
  String? success;
  String? failure;
  String? msg;
  String? colorTitle;
  List<ColorDetails_arr>? colorDetailsArr;

  SubCategoryButtonsDetailsResponse(
      {this.success,
      this.failure,
      this.msg,
      this.colorTitle,
      this.colorDetailsArr});

  SubCategoryButtonsDetailsResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    failure = json['Failure'];
    msg = json['msg'];
    colorTitle = json['Color Title'];
    if (json['ColorCode_arr'] != null) {
      colorDetailsArr = <ColorDetails_arr>[];
      json['ColorCode_arr'].forEach((v) {
        colorDetailsArr!.add(ColorDetails_arr.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Success'] = success;
    data['Failure'] = failure;
    data['msg'] = msg;
    data['Color Title'] = colorTitle;
    if (colorDetailsArr != null) {
      data['ColorDetails_arr'] =
          colorDetailsArr!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class ColorDetails_arr {
  String? id;
  String? title;

  ColorDetails_arr({this.id, this.title});

  ColorDetails_arr.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = this.id;
    data['Title'] = this.title;

    return data;
  }
}
