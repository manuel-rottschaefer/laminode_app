import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SchemaSelectionDialog extends ConsumerWidget {
  final String applicationId;
  final String? selectedSchemaId;
  final Function(String) onSchemaSelected;

  const SchemaSelectionDialog({
    super.key,
    required this.applicationId,
    this.selectedSchemaId,
    required this.onSchemaSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemas = ref.watch(installedSchemasForAppProvider(applicationId));
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (schemas.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text("No schemas installed for this application."),
            ),
          )
        else
          ...schemas.map((schema) {
            final isSelected = schema.id == selectedSchemaId;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s),
              child: InkWell(
                onTap: () {
                  onSchemaSelected(schema.id);
                  Navigator.of(context).pop();
                },
                child: LamiBox(
                  borderColor: isSelected ? theme.colorScheme.primary : null,
                  backgroundColor: isSelected
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.1,
                        )
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.binary,
                        size: 20,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Version: ${schema.version}",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : null,
                              ),
                            ),
                            Text(
                              "Released: ${schema.releaseDate}",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          LucideIcons.check,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
