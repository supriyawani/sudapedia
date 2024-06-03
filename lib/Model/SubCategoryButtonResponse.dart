class SubCategoryButtonResponse {
  String? success;
  String? failure;
  String? msg;
  String? subcategoryName;
  List<ColorCode_arr>? colorcodeArr;

  SubCategoryButtonResponse(
      {this.success,
      this.failure,
      this.msg,
      this.subcategoryName,
      this.colorcodeArr});

  SubCategoryButtonResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    failure = json['Failure'];
    msg = json['msg'];
    subcategoryName = json['SubCategoryName'];
    if (json['ColorCode_arr'] != null) {
      colorcodeArr = <ColorCode_arr>[];
      json['ColorCode_arr'].forEach((v) {
        colorcodeArr!.add(ColorCode_arr.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Success'] = success;
    data['Failure'] = failure;
    data['msg'] = msg;
    data['SubCategoryName'] = subcategoryName;
    if (colorcodeArr != null) {
      data['ColorCode_arr'] = colorcodeArr!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class ColorCode_arr {
  String? id;
  String? title;
  String? textcolor;
  String? code;

  ColorCode_arr({this.id, this.title, this.textcolor, this.code});

  /*ColorCode_arr.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    textcolor = json['text_color'];
    code = json['code'];
  }*/
  factory ColorCode_arr.fromJson(Map<String, dynamic> json) {
    return ColorCode_arr(
      id: json['Id'],
      title: json['Title'],
      textcolor: json['text_color'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = this.id;
    data['Title'] = this.textcolor;
    data['text_color'] = this.textcolor;
    data['code'] = this.code;
    return data;
  }
}
