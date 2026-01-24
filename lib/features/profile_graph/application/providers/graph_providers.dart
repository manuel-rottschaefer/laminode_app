import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import '../../domain/entities/graph_data.dart';
import '../../domain/entities/graph_node.dart';
import '../../domain/use_cases/get_profile_graph_data.dart';
import '../controllers/profile_graph_controller.dart';
import '../../../../core/domain/entities/entries/param_entry.dart';
import '../../../../core/services/graph_debug_service.dart';
import '../../../layer_panel/presentation/providers/layer_panel_provider.dart';
import '../../../param_panel/presentation/providers/param_panel_provider.dart';
import '../../../schema_shop/presentation/providers/schema_shop_provider.dart';

// Use Case Provider
final getProfileGraphDataUseCaseProvider = Provider<GetProfileGraphData>((ref) {
  return GetProfileGraphData();
});

final graphDataProvider = Provider<GraphData>((ref) {
  final useCase = ref.watch(getProfileGraphDataUseCaseProvider);

  // Watch for active schema (schema shop) and active layers (layer panel)
  final activeSchema = ref.watch(
    schemaShopProvider.select((s) => s.activeSchema),
  );
  final layers = ref.watch(layerPanelProvider.select((s) => s.layers));
  final expandedParamName = ref.watch(
    paramPanelProvider.select((s) => s.expandedParamName),
  );

  final activeLayers = layers.where((l) => l.isActive).toList();

  GraphDebugService.talker.info(
    'Generating Graph Data...\n'
    'Active Schema: ${activeSchema?.schemaName ?? "None"}\n'
    'Active Layers: ${activeLayers.length} / ${layers.length}',
  );

  // If no schema loaded and no layers, return empty
  if (activeSchema == null && activeLayers.isEmpty) {
    GraphDebugService.talker.warning(
      'Graph generation skipped: No schema and no active layers.',
    );
    return const GraphData.empty();
  }

  // Identify which categories are "active" based on the active layers.
  // We only show schema structure (categories/params) if the category is present in an active layer.
  final activeCategoryNames = <String>{};
  for (final layer in activeLayers) {
    // Log layer details
    GraphDebugService.talker.debug(
      'Processing Layer: ${layer.layerName} (Category: ${layer.layerCategory}, Params: ${layer.parameters?.length ?? 0})',
    );

    // If layer maps to a specific category, we activate that category text
    if (layer.layerCategory != null && layer.layerCategory!.isNotEmpty) {
      activeCategoryNames.add(layer.layerCategory!);
    }

    // Also include categories derived from parameters present in the layer
    if (layer.parameters != null) {
      for (final param in layer.parameters!) {
        activeCategoryNames.add(param.category.categoryName);
      }
    }
  }

  GraphDebugService.talker.info(
    'Active Categories identified: $activeCategoryNames',
  );

  // 1. Gather ALL categories from the Schema (to ensure structure even without layers)
  // But FILTERED by active categories.
  final allCategoriesMap = <String, CamParamCategory>{};

  if (activeSchema != null) {
    for (final cat in activeSchema.categories) {
      if (activeCategoryNames.contains(cat.categoryName)) {
        allCategoriesMap[cat.categoryName] = cat;
      }
    }
  }

  // 2. Gather Schema Parameters (Base definition)
  // FILTERED by active categories.
  final schemaParamsMap = <String, CamParamEntry>{};
  if (activeSchema != null) {
    for (final p in activeSchema.availableParameters) {
      if (activeCategoryNames.contains(p.category.categoryName)) {
        schemaParamsMap[p.paramName] = p;
      }
    }
  }

  GraphDebugService.talker.debug(
    'Schema Extraction -> Categories: ${allCategoriesMap.length}, Params: ${schemaParamsMap.length}',
  );

  // 3. Gather Layer Overrides (Profile Values) and merge with Schema
  // Last active layer wins for value overrides.
  // If a parameter is in a layer but NOT in schema (custom param?), we add it too.

  final effectiveParamsMap = <String, CamParamEntry>{...schemaParamsMap};

  for (final layer in activeLayers) {
    if (layer.parameters != null) {
      for (final param in layer.parameters!) {
        // Update category map if this layer introduces a new category (unlikely but safe)
        if (!allCategoriesMap.containsKey(param.category.categoryName)) {
          allCategoriesMap[param.category.categoryName] = param.category;
        }

        // Merge/Override parameter
        effectiveParamsMap[param.paramName] = param;
      }
    }
  }

  final allParams = effectiveParamsMap.values.toList();
  final categories = allCategoriesMap.values.toList();

  GraphDebugService.talker.info(
    'Final Graph candidates -> Categories: ${categories.length}, Params: ${allParams.length}',
  );

  if (allParams.isEmpty && categories.isEmpty) {
    return const GraphData.empty();
  }

  // Build parent-to-children relationship based on CamParameter.baseParam
  final parentToChildren = <String, List<String>>{};
  for (final param in allParams) {
    if (param.baseParam != null) {
      parentToChildren
          .putIfAbsent(param.baseParam!, () => [])
          .add(param.paramName);
    }
  }

  final data = useCase.execute(
    categories: categories,
    parameters: allParams,
    parentToChildrenMap: parentToChildren,
  );

  // Apply focus state from paramPanelProvider
  if (expandedParamName != null) {
    final nodes = Map<String, GraphNode>.from(data.nodes);
    if (nodes.containsKey(expandedParamName)) {
      nodes[expandedParamName] = nodes[expandedParamName]!.copyWith(
        isFocused: true,
      );
      return GraphData(nodes: nodes, edges: data.edges);
    }
  }

  return data;
});

final profileGraphControllerProvider = Provider<ProfileGraphController>((ref) {
  return ProfileGraphController(ref);
});

final visualControllerProvider = Provider<ForceDirectedGraphController<String>>(
  (ref) {
    return ref.watch(profileGraphControllerProvider).visualController;
  },
);
