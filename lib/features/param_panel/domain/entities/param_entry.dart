import 'package:laminode_app/core/domain/entities/cam_param.dart';

// A Parameter entry is a stateful representation of a CamParameter in a Profile
class CamParamEntry extends CamParameter {
  final dynamic value;

  CamParamEntry({
    required super.paramName,
    required super.paramTitle,
    required super.quantity,
    required this.value,
  });

  factory CamParamEntry.fromJson(Map<String, dynamic> json) {
    return CamParamEntry(
      paramName: json['paramName'],
      paramTitle: json['paramTitle'],
      quantity: ParamQuantity.fromJson(json['quantity']),
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paramName': paramName,
      'paramTitle': paramTitle,
      'quantity': quantity.toJson(),
      'value': value,
    };
  }
}
