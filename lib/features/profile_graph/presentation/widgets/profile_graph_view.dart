import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/fog_effect.dart';
import 'package:laminode_app/features/evaluation/application/profile_evaluation_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
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
  Rect? _focusedInputRect;
  ForceDirectedGraphController<String>? _visualController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref
          .read(profileGraphControllerProvider)
          .visualController;
      _visualController = controller;
      controller.addListener(_onTransformChange);
    });
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && mounted) {
      setState(() {
        _focusedInputRect = null;
      });
    }
  }

  void _syncControllerWithParam(String? paramName) {
    if (paramName == null) {
      _controller.text = "";
      return;
    }

    if (_focusNode.hasFocus) {
      return;
    }

    final items = ref.read(paramPanelItemsProvider);
    final item = items.cast<ParamPanelItem?>().firstWhere(
      (it) => it?.param.paramName == paramName,
      orElse: () => null,
    );

    final value = item?.param.value?.toString() ?? "";
    if (_controller.text != value) {
      _controller.text = value;
    }
  }

  void _onTransformChange() {
    if (_focusNode.hasFocus && mounted) {
      _updateInputPosition();
    }
  }

  @override
  void dispose() {
    _visualController?.removeListener(_onTransformChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onNodeTap(ParamGraphNode node) {
    final layers = ref.read(layerPanelProvider).layers;
    final paramCategory = node.parameter.category.categoryName;
    int? highestActiveIndex;

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

    final updatedItems = ref.read(paramPanelItemsProvider);
    final updatedItem = updatedItems.cast<ParamPanelItem?>().firstWhere(
      (it) => it?.param.paramName == node.id,
      orElse: () => null,
    );

    if (updatedItem != null) {
      _controller.text = (updatedItem.param.value ?? "").toString();
    } else {
      _controller.text = "";
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateInputPosition();
      _focusNode.requestFocus();
    });
  }

  void _updateInputPosition() {
    final key = ref.read(focusedInputKeyProvider);
    final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final viewport = context.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero, ancestor: viewport);
      setState(() {
        _focusedInputRect = offset & box.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visualController = ref
        .watch(profileGraphControllerProvider)
        .visualController;
    final evalResults = ref.watch(profileEvaluationProvider);

    final focusedParamName = ref.watch(
      paramPanelProvider.select((s) => s.focusedParamName),
    );

    ref.listen(paramPanelItemsProvider, (prev, next) {
      if (focusedParamName != null) {
        _syncControllerWithParam(focusedParamName);
      }
    });

    ref.listen(paramPanelProvider.select((s) => s.focusedParamName), (
      prev,
      next,
    ) {
      if (next != null) {
        _syncControllerWithParam(next);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _updateInputPosition();
        });
      }
    });

    final effectiveValue = focusedParamName != null
        ? evalResults[focusedParamName]
        : null;
    final hintText = effectiveValue?.toString() ?? '';
    final isLocked =
        focusedParamName != null &&
        (ref.watch(
              paramPanelProvider.select(
                (s) => s.lockedParams[focusedParamName],
              ),
            ) ??
            false);

    return Stack(
      children: [
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

        if (_focusedInputRect != null)
          Positioned.fromRect(
            rect: _focusedInputRect!,
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: isLocked,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    color: isLocked ? Colors.white38 : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    letterSpacing: 0.4,
                  ),
                  cursorColor: Colors.white54,
                  cursorWidth: 1,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    counterText: '',
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'monospace',
                      letterSpacing: 0.4,
                    ),
                  ),
                  onChanged: (val) {
                    ref
                        .read(paramPanelProvider.notifier)
                        .updateFocusedParamValue(val);
                  },
                  onSubmitted: (_) => _focusNode.unfocus(),
                  onTapOutside: (_) => _focusNode.unfocus(),
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 16,
          left: 340,
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