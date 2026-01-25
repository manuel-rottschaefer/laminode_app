import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_stack_info.dart';
import 'package:laminode_app/features/param_panel/domain/usecases/get_param_stack.dart';

final getParamStackUseCaseProvider = Provider((ref) => GetParamStackUseCase());

final paramStackProvider = Provider.family<ParamStackInfo, String>((
  ref,
  paramName,
) {
  final activeSchema = ref.watch(
    schemaShopProvider.select((s) => s.activeSchema),
  );
  final layers = ref.watch(layerPanelProvider.select((s) => s.layers));

  return ref
      .read(getParamStackUseCaseProvider)
      .execute(
        paramName: paramName,
        layers: layers,
        activeSchema: activeSchema,
      );
});
