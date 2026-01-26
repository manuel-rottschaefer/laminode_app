import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/presentation/widgets/fog_effect.dart';
import 'package:laminode_app/core/presentation/widgets/app_bar/lami_app_bar.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_panel.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_panel.dart';
import 'package:laminode_app/features/profile_manager/presentation/widgets/profile_panel.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/profile_graph/presentation/widgets/profile_graph_view.dart';

class ProfileEditorScreen extends ConsumerStatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  ConsumerState<ProfileEditorScreen> createState() =>
      _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Column(
        children: [
          if (Theme.of(context).platform == TargetPlatform.linux ||
              Theme.of(context).platform == TargetPlatform.macOS ||
              Theme.of(context).platform == TargetPlatform.windows)
            const LamiAppBar(),
          Expanded(
            child: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => Consumer(
                  builder: (context, ref, child) {
                    final hasProfile = ref.watch(
                      profileManagerProvider.select(
                        (s) => s.currentProfile != null,
                      ),
                    );
                    final hasLayers = ref.watch(
                      layerPanelProvider.select((s) => s.layers.isNotEmpty),
                    );

                    return Stack(
                      children: [
                        // Background (Graph View) - Stays full screen
                        const Positioned.fill(child: ProfileGraphView()),

                        // Sidebars - These move inward
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.l),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left Sidebar
                              _Sidebar(
                                width: 320,
                                child: FogEffect(
                                  padding: AppSpacing.m,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  showLeft: false,
                                  showTop: false,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const ProfilePanel(),
                                      if (hasProfile) ...[
                                        const SizedBox(height: AppSpacing.xl),
                                        const LamiPanel(
                                          baseRadius: 12,
                                          borderWidth: 3,
                                          child: LayerPanel(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              // Right Sidebar
                              if (hasLayers)
                                _Sidebar(
                                  width: 360,
                                  child: FogEffect(
                                    padding: AppSpacing.m,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainer,
                                    showRight: false,
                                    showTop: false,
                                    child: const LamiPanel(
                                      baseRadius: 12,
                                      borderWidth: 3,
                                      child: ParamPanel(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final Widget child;
  final double width;
  const _Sidebar({required this.child, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: child);
  }
}
