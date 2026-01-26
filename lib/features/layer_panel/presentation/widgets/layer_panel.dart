import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';

import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/create_layer_dialog.dart';
import 'package:laminode_app/features/layer_management/presentation/dialogs/find_layers_dialog.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_item.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/schema_layer_item.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';

class LayerPanel extends ConsumerStatefulWidget {
  const LayerPanel({super.key});

  @override
  ConsumerState<LayerPanel> createState() => _LayerPanelState();
}

class _LayerPanelState extends ConsumerState<LayerPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        ref.read(layerPanelProvider.notifier).setSearchQuery('');
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final panelState = ref.watch(layerPanelProvider);
    final allLayers = panelState.layers;
    final searchQuery = panelState.searchQuery.toLowerCase();

    final layers = allLayers.where((layer) {
      if (searchQuery.isEmpty) return true;
      return layer.layerName.toLowerCase().contains(searchQuery);
    }).toList();

    final profileState = ref.watch(profileManagerProvider);
    final currentProfile = profileState.currentProfile;
    final theme = Theme.of(context);

    // If no profile, show placeholder
    if (currentProfile == null) {
      return Center(
        child: Text(
          "Open or create a profile to view layers.",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.disabledColor,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
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
                  focusNode: _searchFocusNode,
                  hintText: "Filter layers...",
                  onChanged: (val) =>
                      ref.read(layerPanelProvider.notifier).setSearchQuery(val),
                ),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
        ),

        // Layers List
        Flexible(
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) {
              if (searchQuery.isNotEmpty) return;
              ref
                  .read(layerPanelProvider.notifier)
                  .reorderLayers(oldIndex, newIndex);
            },
            itemCount: layers.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final entry = layers[index];
              final realIndex = allLayers.indexOf(entry);
              return LayerItem(
                key: ValueKey("layer_${entry.layerName}_$realIndex"),
                entry: entry,
                index: realIndex,
              );
            },
          ),
        ),

        if (layers.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                searchQuery.isEmpty
                    ? "No additional layers present."
                    : "No layers found for your search",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ),
          ),

        Column(
          children: [
            SchemaLayerItem(profile: currentProfile),
            const SizedBox(height: AppSpacing.m),

            // Action Buttons (Moved to Bottom)
            Row(
              children: [
                Expanded(
                  child: LamiButton(
                    icon: Icons.add_rounded,
                    label: "Create Layer",
                    inactive: currentProfile.schema == null,
                    onPressed: () {
                      showLamiDialog(
                        context: context,
                        model: const LamiDialogModel(
                          title: "New Profile Layer",
                          content: CreateLayerDialog(),
                          maxHeight: 600,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: LamiButton(
                    icon: Icons.file_download_outlined,
                    label: "Find Layers",
                    onPressed: () {
                      showLamiDialog(
                        context: context,
                        model: const LamiDialogModel(
                          title: "Local Layers",
                          content: FindLayersDialog(),
                          maxHeight: 600,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
