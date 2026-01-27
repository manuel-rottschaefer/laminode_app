import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:laminode_app/features/evaluation/application/providers.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/profile_graph/application/controllers/profile_graph_controller.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/get_processed_graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/get_profile_graph_data.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/evaluation/application/profile_evaluation_provider.dart';

// Use Case Providers
final getProfileGraphDataUseCaseProvider = Provider<GetProfileGraphData>((ref) {
  return GetProfileGraphData();
});

final getProcessedGraphDataUseCaseProvider = Provider<GetProcessedGraphData>((
  ref,
) {
  return GetProcessedGraphData(ref.watch(getProfileGraphDataUseCaseProvider));
});

final graphDataProvider = Provider<GraphData>((ref) {
  final useCase = ref.watch(getProcessedGraphDataUseCaseProvider);

  final activeSchema = ref.watch(
    schemaShopProvider.select((s) => s.activeSchema),
  );
  final layers = ref.watch(layerPanelProvider.select((s) => s.layers));
  final expandedParamName = ref.watch(
    paramPanelProvider.select((s) => s.expandedParamName),
  );
  final focusedParamName = ref.watch(
    paramPanelProvider.select((s) => s.focusedParamName),
  );
  final lockedParams = ref.watch(
    paramPanelProvider.select((s) => s.lockedParams),
  );
  final branchedParamNames = ref.watch(
    paramPanelProvider.select((s) => s.branchedParamNames),
  );
  final engine = ref.watch(evaluationEngineProvider);
  final evaluationContext = ref.watch(profileEvaluationProvider);

  return useCase.execute(
    activeSchema: activeSchema,
    layers: layers,
    expandedParamName: expandedParamName,
    focusedParamName: focusedParamName,
    lockedParams: lockedParams,
    branchedParamNames: branchedParamNames,
    engine: engine,
    evaluationContext: evaluationContext,
  );
});

final focusedInputKeyProvider = Provider<GlobalKey>((ref) {
  return GlobalKey(debugLabel: 'focusedGraphInput');
});

final profileGraphControllerProvider =
    ChangeNotifierProvider<ProfileGraphController>((ref) {
      final controller = ProfileGraphController();
      controller.setRef(ref);
      return controller;
    });

final visualControllerProvider = Provider<ForceDirectedGraphController<String>>(
  (ref) {
    return ref.watch(profileGraphControllerProvider).visualController;
  },
);
