import 'package:laminode_app/core/domain/entities/lami_layer.dart';

class LamiProfile<T extends LamiLayer> {
  final String profileName;
  final List<T> layers;

  const LamiProfile({required this.profileName, required this.layers});
}
