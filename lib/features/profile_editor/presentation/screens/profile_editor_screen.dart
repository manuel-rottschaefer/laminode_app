import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/presentation/widgets/fog_effect.dart';
import 'package:laminode_app/core/presentation/widgets/app_bar/lami_app_bar.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_panel.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_panel.dart';
import 'package:laminode_app/features/profile_manager/presentation/widgets/profile_panel.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileEditorScreen extends ConsumerStatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  ConsumerState<ProfileEditorScreen> createState() =>
      _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fogColor = colorScheme.surfaceContainer;

    return Scaffold(
      backgroundColor: fogColor,
      body: Column(
        children: [
          if (Theme.of(context).platform == TargetPlatform.linux ||
              Theme.of(context).platform == TargetPlatform.macOS ||
              Theme.of(context).platform == TargetPlatform.windows)
            const LamiAppBar(),
          Expanded(
            child: Stack(
              children: [
                // Background (Graph Placeholder)
                Positioned.fill(
                  child: Container(
                    color: fogColor,
                    child: const Center(
                      child: Icon(
                        LucideIcons.grid,
                        size: 100,
                        color: Colors.white10,
                      ),
                    ),
                  ),
                ),

                // Sidebars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Sidebar
                    _Sidebar(
                      width: 320,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FogEffect(
                            padding: AppSpacing.m,
                            color: fogColor,
                            showLeft: false,
                            showTop: false,
                            child: const ProfilePanel(),
                          ),
                          Expanded(
                            child: FogEffect(
                              padding: AppSpacing.m,
                              color: fogColor,
                              showLeft: false,
                              showBottom: false,
                              child: const LamiPanel(
                                baseRadius: 12,
                                borderWidth: 3,
                                child: LayerPanel(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Sidebar
                    _Sidebar(
                      width: 360,
                      child: FogEffect(
                        padding: AppSpacing.m,
                        color: fogColor,
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
              ],
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
