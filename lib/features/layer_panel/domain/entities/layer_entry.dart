import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/lami_layer.dart';

// A layer entry is a stateful representation of a LamiLayer in a Profile
class LamiLayerEntry extends LamiLayer<CamParamEntry> {
  final String layerAuthor;
  final String layerDescription;
  final String? layerCategory;
  final bool isActive;
  final bool isLocked;

  const LamiLayerEntry({
    required super.layerName,
    required super.parameters,
    required this.layerAuthor,
    required this.layerDescription,
    this.layerCategory,
    this.isActive = true,
    this.isLocked = false,
  });

  LamiLayerEntry copyWith({
    String? layerName,
    List<CamParamEntry>? parameters,
    String? layerAuthor,
    String? layerDescription,
    String? layerCategory,
    bool? isActive,
    bool? isLocked,
  }) {
    return LamiLayerEntry(
      layerName: layerName ?? this.layerName,
      parameters: parameters ?? this.parameters,
      layerAuthor: layerAuthor ?? this.layerAuthor,
      layerDescription: layerDescription ?? this.layerDescription,
      layerCategory: layerCategory ?? this.layerCategory,
      isActive: isActive ?? this.isActive,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
