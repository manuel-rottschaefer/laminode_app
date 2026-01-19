import 'package:laminode_app/core/domain/entities/cam_param.dart';

abstract class LamiLayer<T extends CamParameter> {
  final String layerName;
  final List<T>? parameters;

  const LamiLayer({required this.layerName, required this.parameters});
}
