import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/layer_panel/data/repositories/layer_panel_repository_impl.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/add_layer.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/get_layers.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/remove_layer.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/update_layer_name.dart';

// Repository Provider
final layerPanelRepositoryProvider = Provider<LayerPanelRepository>((ref) {
  return LayerPanelRepositoryImpl();
});

// UseCase Providers
final getLayersUseCaseProvider = Provider((ref) {
  return GetLayersUseCase(ref.watch(layerPanelRepositoryProvider));
});

final addLayerUseCaseProvider = Provider((ref) {
  return AddLayerUseCase(ref.watch(layerPanelRepositoryProvider));
});

final removeLayerUseCaseProvider = Provider((ref) {
  return RemoveLayerUseCase(ref.watch(layerPanelRepositoryProvider));
});

final updateLayerNameUseCaseProvider = Provider((ref) {
  return UpdateLayerNameUseCase(ref.watch(layerPanelRepositoryProvider));
});
