// A ParamQuantity describes the type of parameter being represented
class ParamQuantity {
  final String quantityName;
  final String quantityUnit;
  final String quantitySymbol;

  ParamQuantity({
    required this.quantityName,
    required this.quantityUnit,
    required this.quantitySymbol,
  });

  factory ParamQuantity.fromJson(Map<String, dynamic> json) {
    return ParamQuantity(
      quantityName: json['quantityName'],
      quantityUnit: json['quantityUnit'],
      quantitySymbol: json['quantitySymbol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantityName': quantityName,
      'quantityUnit': quantityUnit,
      'quantitySymbol': quantitySymbol,
    };
  }
}

// Parameters are grouped into categories for better organization
abstract class CamParamCategory {
  final String categoryName;
  final String categoryTitle;
  final String categoryColorName;

  CamParamCategory({
    required this.categoryName,
    required this.categoryTitle,
    required this.categoryColorName,
  });
}

// A CamParameter is the atomic unit of configuration for a CAM profile
abstract class CamParameter {
  final String paramName;
  final String paramTitle;
  final ParamQuantity quantity;
  final CamParamCategory category;
  final String? baseParam;

  CamParameter({
    required this.paramName,
    required this.paramTitle,
    required this.quantity,
    required this.category,
    this.baseParam,
  });
}
