import "package:flutter/material.dart";
import "package:laminode_app/core/presentation/dialog/lami_dialog.dart";
import "package:laminode_app/core/presentation/widgets/lami_action_widgets.dart";
import "package:laminode_app/core/theme/app_spacing.dart";
import "package:laminode_app/core/presentation/widgets/app_bar/lami_window_button.dart";
import "package:laminode_app/features/schema_shop/presentation/widgets/schema_shop_dialog.dart";
import "package:lucide_icons/lucide_icons.dart";
import "package:window_manager/window_manager.dart";

class LamiAppBar extends StatelessWidget {
  const LamiAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              child: Row(
                children: [
                  Icon(
                    Icons.architecture_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Text(
                    "LamiNode",
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      "v0.1",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.63),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  LamiIcon(
                    icon: LucideIcons.shoppingBag,
                    size: 16,
                    padding: 4,
                    onPressed: () {
                      showLamiDialog(
                        context: context,
                        model: const LamiDialogModel(
                          title: "Schema Shop",
                          content: SchemaShopDialog(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Row(
              children: [
                LamiWindowButton(
                  icon: Icons.minimize_rounded,
                  onPressed: () {
                    windowManager.minimize();
                  },
                  tooltip: "Minimize",
                ),
                LamiWindowButton(
                  icon: Icons.crop_square_rounded,
                  onPressed: () async {
                    bool isMaximized = await windowManager.isMaximized();
                    if (isMaximized) {
                      windowManager.unmaximize();
                    } else {
                      windowManager.maximize();
                    }
                  },
                  tooltip: "Maximize",
                ),
                LamiWindowButton(
                  icon: Icons.close_rounded,
                  onPressed: () {
                    windowManager.close();
                  },
                  tooltip: "Close",
                  isClose: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
