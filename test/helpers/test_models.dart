import 'package:laminode_app/core/data/models/cam_category_entry_model.dart';
import 'package:laminode_app/core/data/models/param_entry_model.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/layer_panel/data/models/layer_entry_model.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';

class TestModels {
  static const tProfileApplication = ProfileApplication(
    id: 'test-id',
    name: 'Test App',
    vendor: 'Test Vendor',
    version: '1.0.0',
  );

  static const tCategoryModel = CamCategoryEntryModel(
    categoryName: 'quality',
    categoryTitle: 'Quality',
    categoryColorName: '0xFF2196F3',
  );

  static final tParamModel = CamParamEntryModel(
    paramName: 'layer_height',
    paramTitle: 'Layer Height',
    paramDescription: 'The height of each layer.',
    quantity: const ParamQuantity(
      quantityName: 'length',
      quantityUnit: 'millimeters',
      quantitySymbol: 'mm',
    ),
    category: tCategoryModel.toEntity(),
    value: 0.2,
  );

  static const tLayerEntryModel = LayerEntryModel(
    layerName: 'Test Layer',
    layerAuthor: 'Admin',
    layerDescription: 'A test layer description',
    isActive: true,
    isLocked: false,
    parameters: [],
  );
}
