import 'package:laminode_app/core/domain/entities/lami_layer.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';

// A layer entry is a stateful representation of a LamiLayer in a Profile
class LamiLayerEntry extends LamiLayer<CamParamEntry> {
  final String layerAuthor;
  String layerDescription;
  bool isActive;
  bool isLocked;

  LamiLayerEntry({
    required super.layerName,
    required super.parameters,
    required this.layerAuthor,
    required this.layerDescription,
    this.isActive = true,
    this.isLocked = false,
  });
}
