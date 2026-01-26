import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/fog_effect.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_providers.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'graph_controls.dart';
import 'profile_graph_components.dart';

class ProfileGraphView extends ConsumerStatefulWidget {
  const ProfileGraphView({super.key});

  @override
  ConsumerState<ProfileGraphView> createState() => _ProfileGraphViewState();
}

class _ProfileGraphViewState extends ConsumerState<ProfileGraphView> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNodeTap(ParamGraphNode node) {
    final layers = ref.read(layerPanelProvider).layers;
    final items = ref.read(paramPanelItemsProvider);

    // Find the item to get its category and name
    final item = items.firstWhere(
      (it) => it.param.paramName == node.id,
      orElse: () => items.first,
    );

    final paramCategory = item.param.category.categoryName;
    int? highestActiveIndex;

    // Find highest active layer for this category
    for (int i = 0; i < layers.length; i++) {
      if (layers[i].layerCategory == paramCategory && layers[i].isActive) {
        highestActiveIndex = i;
      }
    }

    if (highestActiveIndex != null) {
      ref
          .read(paramPanelProvider.notifier)
          .setSelectedLayerIndex(node.id, highestActiveIndex);
    }

    ref.read(paramPanelProvider.notifier).navigateToParam(node.id);

    // Sync controller with current value after selection
    final updatedItems = ref.read(paramPanelItemsProvider);
    final updatedItem = updatedItems.firstWhere(
      (it) => it.param.paramName == node.id,
      orElse: () => updatedItems.first,
    );

    _controller.text = (updatedItem.param.value ?? "").toString();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visualController = ref
        .watch(profileGraphControllerProvider)
        .visualController;

    return Stack(
      children: [
        // Hidden input for the whole graph
        Opacity(
          opacity: 0,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (val) {
              ref
                  .read(paramPanelProvider.notifier)
                  .updateFocusedParamValue(val);
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            ref.read(paramPanelProvider.notifier).clearFocus();
            _focusNode.unfocus();
          },
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final currentScale = visualController.scale;
                final delta = pointerSignal.scrollDelta.dy;
                if (delta > 0) {
                  visualController.scale = currentScale / 1.1;
                } else {
                  visualController.scale = currentScale * 1.1;
                }
              }
            },
            child: ForceDirectedGraphWidget<String>(
              controller: visualController,
              nodesBuilder: (context, id) => ProfileGraphNodesBuilder(
                id: id,
                onNodeTap: () {
                  final graphData = ref.read(graphDataProvider);
                  final nodeData = graphData.nodes[id];
                  if (nodeData is ParamGraphNode) {
                    _onNodeTap(nodeData);
                  }
                },
              ),
              edgesBuilder: (context, a, b, distance) =>
                  ProfileGraphEdgesBuilder(
                    a: a,
                    b: b,
                    distance: distance,
                    visualController: visualController,
                  ),
            ),
          ),
        ),
        // Floating Action Buttons
        Positioned(
          bottom: 16,
          left: 340, // Offset from the left sidebar
          child: FogEffect(
            padding: 4,
            color: colorScheme.surfaceContainer.withValues(alpha: 0.4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingGraphButton(
                  icon: Icons.center_focus_strong_rounded,
                  onPressed: () {
                    ref.read(profileGraphControllerProvider).center();
                  },
                  tooltip: 'Center Graph',
                ),
                const SizedBox(height: 8),
                FloatingGraphButton(
                  icon: Icons.save_alt_rounded,
                  onPressed: () {
                    ref
                        .read(profileGraphControllerProvider)
                        .saveCurrentSnapshot();
                  },
                  tooltip: 'Save Snapshot',
                ),
                const SizedBox(height: 8),
                FloatingGraphButton(
                  icon: Icons.file_open_rounded,
                  onPressed: () {
                    ref.read(profileGraphControllerProvider).loadSnapshot();
                  },
                  tooltip: 'Load Snapshot',
                ),
                const SizedBox(height: 8),
                FloatingGraphButton(
                  icon: Icons.add_rounded,
                  onPressed: () {
                    final controller = ref.read(visualControllerProvider);
                    controller.scale = controller.scale * 1.2;
                  },
                  tooltip: 'Zoom In',
                ),
                const SizedBox(height: 8),
                FloatingGraphButton(
                  icon: Icons.remove_rounded,
                  onPressed: () {
                    final controller = ref.read(visualControllerProvider);
                    controller.scale = controller.scale / 1.2;
                  },
                  tooltip: 'Zoom Out',
                ),
                const SizedBox(height: 8),
                const ThemeToggleButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
