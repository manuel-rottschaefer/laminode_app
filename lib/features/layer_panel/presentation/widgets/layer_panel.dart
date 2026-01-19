import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/create_layer_dialog.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_item.dart';

class LayerPanel extends ConsumerStatefulWidget {
  const LayerPanel({super.key});

  @override
  ConsumerState<LayerPanel> createState() => _LayerPanelState();
}

class _LayerPanelState extends ConsumerState<LayerPanel> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final layers = ref.watch(layerPanelProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LamiPanelHeader(
          icon: Icons.layers_rounded,
          title: "Profile Layers",
          trailing: LamiToggleIcon(
            value: _isSearchVisible,
            icon: Icons.search_rounded,
            toggledIcon: Icons.search_off_rounded,
            onChanged: (val) => _toggleSearch(),
          ),
        ),
        const SizedBox(height: AppSpacing.s),

        // Search Box (Animated)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: _isSearchVisible ? null : 0,
            child: Column(
              children: [
                LamiSearch(
                  controller: _searchController,
                  hintText: "Filter layers...",
                ),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
        ),

        // Layers List
        Expanded(
          child: layers.isEmpty
              ? Center(
                  child: Text(
                    "No layers present in this profile.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: layers.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return LayerItem(entry: layers[index], index: index);
                  },
                ),
        ),

        const SizedBox(height: AppSpacing.m),

        // Action Buttons (Moved to Bottom)
        Row(
          children: [
            Expanded(
              child: LamiButton(
                icon: Icons.add_rounded,
                label: "Add Layer",
                onPressed: () {
                  showLamiDialog(
                    context: context,
                    model: const LamiDialogModel(
                      title: "New Profile Layer",
                      content: CreateLayerDialog(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: LamiButton(
                icon: Icons.file_download_outlined,
                label: "Import",
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
