import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/core/data/models/param_entry_model.dart';

class LayerEntryModel {
  final String layerName;
  final List<CamParamEntryModel>? parameters;
  final String layerAuthor;
  final String layerDescription;
  final bool isActive;
  final bool isLocked;

  const LayerEntryModel({
    required this.layerName,
    this.parameters,
    required this.layerAuthor,
    required this.layerDescription,
    this.isActive = true,
    this.isLocked = false,
  });

  factory LayerEntryModel.fromEntity(LamiLayerEntry entity) {
    return LayerEntryModel(
      layerName: entity.layerName,
      parameters: entity.parameters
          ?.map((e) => CamParamEntryModel.fromEntity(e))
          .toList(),
      layerAuthor: entity.layerAuthor,
      layerDescription: entity.layerDescription,
      isActive: entity.isActive,
      isLocked: entity.isLocked,
    );
  }

  LamiLayerEntry toEntity() {
    return LamiLayerEntry(
      layerName: layerName,
      parameters: parameters?.map((e) => e.toEntity()).toList(),
      layerAuthor: layerAuthor,
      layerDescription: layerDescription,
      isActive: isActive,
      isLocked: isLocked,
    );
  }

  factory LayerEntryModel.fromJson(Map<String, dynamic> json) {
    return LayerEntryModel(
      layerName: json['layerName'],
      parameters: (json['parameters'] as List<dynamic>?)
          ?.map((e) => CamParamEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      layerAuthor: json['layerAuthor'],
      layerDescription: json['layerDescription'] ?? '',
      isActive: json['isActive'] ?? true,
      isLocked: json['isLocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layerName': layerName,
      'parameters': parameters?.map((e) => e.toJson()).toList(),
      'layerAuthor': layerAuthor,
      'layerDescription': layerDescription,
      'isActive': isActive,
      'isLocked': isLocked,
    };
  }
}
