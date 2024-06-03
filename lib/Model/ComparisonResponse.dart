
class ColorCode {
  final String id;
  final String title;
  final String textColor;
  final String code;

  ColorCode({
    required this.id,
    required this.title,
    required this.textColor,
    required this.code,
  });

  factory ColorCode.fromJson(Map<String, dynamic> json) {
    return ColorCode(
      id: json['Id'],
      title: json['Title'],
      textColor: json['text_color'],
      code: json['code'],
    );
  }
}

class Subcategory {
  final String id;
  final String name;
  final List<ColorCode> colorCodes;

  Subcategory({
    required this.id,
    required this.name,
    required this.colorCodes,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    var list = json['ColorCode_arr'] as List;
    List<ColorCode> colorCodeList =
        list.map((i) => ColorCode.fromJson(i)).toList();

    return Subcategory(
      id: json['Id'],
      name: json['SubCategoryName'],
      colorCodes: colorCodeList,
    );
  }
}

class ComparisonResponse {
  final String name;
  final List<Subcategory> subcategories;

  ComparisonResponse({
    required this.name,
    required this.subcategories,
  });

  factory ComparisonResponse.fromJson(Map<String, dynamic> json) {
    var list = json['Subcategories_arr'] as List;
    List<Subcategory> subcategoryList =
        list.map((i) => Subcategory.fromJson(i)).toList();

    return ComparisonResponse(
      name: json['CategoryName'],
      subcategories: subcategoryList,
    );
  }
}
