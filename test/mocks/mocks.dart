import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/profile_manager/domain/repositories/profile_repository.dart';
import 'package:laminode_app/features/layer_management/data/datasources/layer_local_data_source.dart';
import 'package:laminode_app/features/layer_management/domain/repositories/layer_management_repository.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/get_layers.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/add_layer.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/add_empty_layer.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/remove_layer.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/update_layer_name.dart';
import 'package:laminode_app/features/schema_shop/domain/repositories/schema_shop_repository.dart';

class MockLayerPanelRepository extends Mock implements LayerPanelRepository {}

class MockLayerManagementRepository extends Mock
    implements LayerManagementRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockLayerLocalDataSource extends Mock implements LayerLocalDataSource {}

class MockGetLayersUseCase extends Mock implements GetLayersUseCase {}

class MockAddLayerUseCase extends Mock implements AddLayerUseCase {}

class MockAddEmptyLayerUseCase extends Mock implements AddEmptyLayerUseCase {}

class MockRemoveLayerUseCase extends Mock implements RemoveLayerUseCase {}

class MockUpdateLayerNameUseCase extends Mock
    implements UpdateLayerNameUseCase {}

class MockSchemaShopRepository extends Mock implements SchemaShopRepository {}
