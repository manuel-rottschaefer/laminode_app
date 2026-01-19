import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/core/data/models/param_entry_model.dart';

class LayerEntryModel extends LamiLayerEntry {
  LayerEntryModel({
    required super.layerName,
    required super.parameters,
    required super.layerAuthor,
    required super.layerDescription,
    bool isActive = true,
    bool isLocked = false,
  });

  factory LayerEntryModel.fromJson(Map<String, dynamic> json) {
    return LayerEntryModel(
      layerName: json['layerName'],
      parameters: (json['parameters'] as List<dynamic>?)
          ?.map((e) => CamParamEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      layerAuthor: json['layerAuthor'],
      layerDescription: json['layerDescription'],
      isActive: json['isActive'],
      isLocked: json['isLocked'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layerName': layerName,
      'parameters': parameters
          ?.map((e) => (e as CamParamEntryModel).toJson())
          .toList(),
      'layerAuthor': layerAuthor,
      'layerDescription': layerDescription,
      'isActive': isActive,
      'isLocked': isLocked,
    };
  }
}
