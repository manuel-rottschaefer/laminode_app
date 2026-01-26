import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/services/graph_debug_service.dart';
import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'get_profile_graph_data.dart';

class GetProcessedGraphData {
  final GetProfileGraphData _getProfileGraphData;

  GetProcessedGraphData(this._getProfileGraphData);

  GraphData execute({
    required CamSchemaEntry? activeSchema,
    required List<LamiLayerEntry> layers,
    required String? expandedParamName,
    required Map<String, bool> lockedParams,
    required Set<String> branchedParamNames,
    required EvaluationEngine engine,
  }) {
    final activeLayers = layers.where((l) => l.isActive).toList();

    GraphDebugService.talker.info(
      'Generating Graph Data...\n'
      'Active Schema: ${activeSchema?.schemaName ?? "None"}\n'
      'Active Layers: ${activeLayers.length} / ${layers.length}',
    );

    if (activeSchema == null && activeLayers.isEmpty) {
      GraphDebugService.talker.warning(
        'Graph generation skipped: No schema and no active layers.',
      );
      return const GraphData.empty();
    }

    final activeCategoryNames = <String>{};
    for (final layer in activeLayers) {
      if (layer.layerCategory != null && layer.layerCategory!.isNotEmpty) {
        activeCategoryNames.add(layer.layerCategory!);
      }

      if (layer.parameters != null) {
        for (final param in layer.parameters!) {
          activeCategoryNames.add(param.category.categoryName);
        }
      }
    }

    final allCategoriesMap = <String, CamParamCategory>{};
    if (activeSchema != null) {
      for (final cat in activeSchema.categories) {
        if (activeCategoryNames.contains(cat.categoryName)) {
          allCategoriesMap[cat.categoryName] = cat;
        }
      }
    }

    final schemaParamsMap = <String, CamParamEntry>{};
    if (activeSchema != null) {
      for (final p in activeSchema.availableParameters) {
        schemaParamsMap[p.paramName] = p;
      }
    }

    final effectiveParamsMap = <String, CamParamEntry>{...schemaParamsMap};

    for (final layer in activeLayers) {
      final l = layer as dynamic;
      if (l.parameters != null) {
        for (final param in l.parameters!) {
          if (!allCategoriesMap.containsKey(param.category.categoryName)) {
            allCategoriesMap[param.category.categoryName] = param.category;
            activeCategoryNames.add(param.category.categoryName);
          }
          effectiveParamsMap[param.paramName] = param;
        }
      }
    }

    final globalChildToParent = <String, String>{};
    final globalParentToChildren = <String, List<String>>{};

    for (final param in effectiveParamsMap.values) {
      if (param.baseParam != null && param.baseParam!.isNotEmpty) {
        globalChildToParent[param.paramName] = param.baseParam!;
        globalParentToChildren
            .putIfAbsent(param.baseParam!, () => [])
            .add(param.paramName);
      }
      for (final childRel in param.children) {
        globalChildToParent[childRel.childParamName] = param.paramName;
        globalParentToChildren
            .putIfAbsent(param.paramName, () => [])
            .add(childRel.childParamName);
      }
    }

    final activeParams = <String, CamParamEntry>{};
    for (final param in effectiveParamsMap.values) {
      if (activeCategoryNames.contains(param.category.categoryName)) {
        activeParams[param.paramName] = param;
      }
    }

    bool added;
    do {
      added = false;
      final currentKeys = activeParams.keys.toList();
      for (final id in currentKeys) {
        final p = activeParams[id]!;
        final parentId = globalChildToParent[p.paramName] ?? p.baseParam;

        if (parentId != null && parentId.isNotEmpty) {
          if (!activeParams.containsKey(parentId)) {
            final parent = effectiveParamsMap[parentId];
            if (parent != null) {
              activeParams[parentId] = parent;
              added = true;
            }
          }
        }
      }
    } while (added);

    bool branchedAdded;
    do {
      branchedAdded = false;
      final currentKeys = activeParams.keys.toList();
      for (final id in currentKeys) {
        if (branchedParamNames.contains(id)) {
          final children = globalParentToChildren[id];
          if (children != null) {
            for (final childId in children) {
              if (!activeParams.containsKey(childId)) {
                final child = effectiveParamsMap[childId];
                if (child != null) {
                  activeParams[childId] = child;
                  branchedAdded = true;
                }
              }
            }
          }
        }
      }
    } while (branchedAdded);

    final allParams = activeParams.values.toList();
    final categories = allCategoriesMap.values.toList();

    if (allParams.isEmpty && categories.isEmpty) {
      return const GraphData.empty();
    }

    final context = <String, dynamic>{};
    for (final p in effectiveParamsMap.values) {
      context[p.paramName] = p.value ?? p.quantity.fallbackValue;
    }

    final enabledParams = <CamParamEntry>[];
    for (final p in allParams) {
      if (p.enabledCondition.isEmpty) {
        enabledParams.add(p);
        continue;
      }

      try {
        final isEnabled = engine.evaluate(
          p.enabledCondition.expression,
          context,
        );
        if (isEnabled == true) {
          enabledParams.add(p);
        }
      } catch (e) {
        enabledParams.add(p);
      }
    }

    final parentToChildrenMap = <String, List<String>>{};
    for (final param in enabledParams) {
      final schemaChildren = globalParentToChildren[param.paramName];
      if (schemaChildren != null && schemaChildren.isNotEmpty) {
        parentToChildrenMap[param.paramName] = schemaChildren;
      }
    }

    final data = _getProfileGraphData.execute(
      categories: categories,
      parameters: enabledParams,
      parentToChildrenMap: parentToChildrenMap,
      branchedParamNames: branchedParamNames,
    );

    if (expandedParamName != null || lockedParams.isNotEmpty) {
      final nodes = Map<String, GraphNode>.from(data.nodes);
      bool changed = false;

      for (final id in nodes.keys) {
        final isFocused = id == expandedParamName;
        final isLocked = lockedParams[id] ?? false;

        if (nodes[id]!.isFocused != isFocused ||
            nodes[id]!.isLocked != isLocked) {
          nodes[id] = nodes[id]!.copyWith(
            isFocused: isFocused,
            isLocked: isLocked,
          );
          changed = true;
        }
      }

      if (changed) {
        return GraphData(nodes: nodes, edges: data.edges);
      }
    }

    return data;
  }
}
