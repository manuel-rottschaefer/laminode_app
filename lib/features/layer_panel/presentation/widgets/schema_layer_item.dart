import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dashed_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/schema_selection_dialog.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/schema_shop_dialog.dart';

class SchemaLayerItem extends ConsumerWidget {
  final ProfileEntity profile;

  const SchemaLayerItem({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final schemaId = profile.schemaId;
    final schema = schemaId != null
        ? ref.watch(schemaByIdProvider(schemaId))
        : null;

    final content = Container(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Icon(
            LucideIcons.binary,
            size: 20,
            color: schemaId == null
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  schemaId == null
                      ? "Select Schema"
                      : "${profile.application.name} Schema",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: schemaId == null
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.primary,
                  ),
                ),
                if (schema != null)
                  Row(
                    children: [
                      Text(
                        "Schema Version: ${schema.version}",
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  )
                else if (schemaId != null)
                  Text(
                    "Schema missing or uninstalled",
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.error,
                    ),
                  )
                else
                  Text(
                    "No schema assigned to this profile",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          if (schemaId != null)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 16),
              onPressed: () {
                ref.read(profileManagerProvider.notifier).setSchema(null);
              },
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(AppSpacing.xs),
              splashRadius: 20,
              color: theme.colorScheme.onSurfaceVariant,
            )
          else
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: schemaId == null
          ? LamiDashedBox(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.s,
              ),
              borderColor: theme.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.5,
              ),
              child: InkWell(
                onTap: () => _showSelectionDialog(context, ref),
                borderRadius: BorderRadius.circular(8),
                child: content,
              ),
            )
          : LamiBox(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.s,
              ),
              child: InkWell(
                onTap: () => _showSelectionDialog(context, ref),
                borderRadius: BorderRadius.circular(8),
                child: content,
              ),
            ),
    );
  }

  void _showSelectionDialog(BuildContext context, WidgetRef ref) {
    showLamiDialog(
      context: context,
      model: LamiDialogModel(
        title: "Select Schema",
        content: SchemaSelectionDialog(
          applicationId: profile.application.id,
          selectedSchemaId: profile.schemaId,
          onSchemaSelected: (id) {
            ref.read(profileManagerProvider.notifier).setSchema(id);
          },
        ),
        actions: [
          LamiButton(
            icon: LucideIcons.logOut,
            label: "Quit",
            onPressed: () => Navigator.of(context).pop(),
          ),
          LamiButton(
            icon: LucideIcons.shoppingBag,
            label: "Shop",
            onPressed: () {
              showLamiDialog(
                context: context,
                model: const LamiDialogModel(
                  title: "Schema Shop",
                  content: SchemaShopDialog(),
                  maxHeight: 700,
                  maxWidth: 800,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
