import 'package:laminode_app/core/domain/entities/lami_layer.dart';

abstract class LamiProfile {
  final String profileName;
  final List<LamiLayer> layers;

  LamiProfile({required this.profileName, required this.layers});
}
