import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/components/value_input.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/components/value_constraints.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dropdown.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';

class ValueTab extends ConsumerStatefulWidget {
  final ParamPanelItem item;

  const ValueTab({super.key, required this.item});

  @override
  ConsumerState<ValueTab> createState() => _ValueTabState();
}

class _ValueTabState extends ConsumerState<ValueTab> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    final initialValue =
        (widget.item.param.value ?? widget.item.param.evalSuggest()).toString();
    _controller = TextEditingController(text: initialValue);
  }

  @override
  void didUpdateWidget(ValueTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue =
        (widget.item.param.value ?? widget.item.param.evalSuggest()).toString();
    if (newValue != _controller.text) {
      _controller.text = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = LamiColor.fromString(
      widget.item.param.category.categoryColorName,
    ).value;

    final layers = ref.watch(layerPanelProvider.select((s) => s.layers));
    final paramCategory = widget.item.param.category.categoryName;
    final paramName = widget.item.param.paramName;

    final matchingLayers = <_LayerOption>[];
    for (int i = 0; i < layers.length; i++) {
      if (layers[i].layerCategory == paramCategory) {
        matchingLayers.add(_LayerOption(index: i, name: layers[i].layerName));
      }
    }

    final selectedLayerIndex = ref.watch(
      paramPanelProvider.select((s) => s.selectedLayerIndices[paramName]),
    );

    // Auto-select first matching layer if none selected
    if (selectedLayerIndex == null && matchingLayers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(paramPanelProvider.notifier)
            .setSelectedLayerIndex(paramName, matchingLayers.first.index);
      });
    }

    return LamiBox(
      backgroundColor: colorScheme.surface,
      borderColor: categoryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.m),
          if (matchingLayers.isNotEmpty)
            _buildLayerDropdown(
              context,
              matchingLayers,
              selectedLayerIndex,
              categoryColor,
            ),
          const SizedBox(height: AppSpacing.l),
          ValueInput(item: widget.item, controller: _controller),
          const SizedBox(height: AppSpacing.m),
          const ValueConstraints(),
        ],
      ),
    );
  }

  Widget _buildLayerDropdown(
    BuildContext context,
    List<_LayerOption> options,
    int? selectedIndex,
    Color categoryColor,
  ) {
    return LamiDropdown<int>(
      label: 'Layer Source',
      value: selectedIndex,
      items: options.map((opt) {
        return DropdownMenuItem<int>(
          value: opt.index,
          child: Text(
            opt.name,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          ref
              .read(paramPanelProvider.notifier)
              .setSelectedLayerIndex(widget.item.param.paramName, val);
        }
      },
      selectedItemBuilder: (context) {
        return options.map((opt) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Icon(
                  Icons.layers_rounded,
                  size: 14,
                  color: categoryColor.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    opt.name.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.2,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

class _LayerOption {
  final int index;
  final String name;
  _LayerOption({required this.index, required this.name});
}
