import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/schema_properties_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/categories_editor_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/adapter_editor_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_list_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_conf_widget.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SchemaEditorBody extends ConsumerWidget {
  final SchemaEditorViewMode viewMode;

  const SchemaEditorBody({super.key, required this.viewMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (viewMode) {
      case SchemaEditorViewMode.schema:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left side: Properties (Top) + Categories (Bottom)
            Expanded(
              flex: 4,
              child: Column(
                children: const [
                  SchemaPropertiesWidget(),
                  SizedBox(height: AppSpacing.xl),
                  Expanded(child: CategoriesEditorWidget()),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            // Right side: Adapter Code
            const Expanded(flex: 6, child: AdapterEditorWidget()),
          ],
        );
      case SchemaEditorViewMode.parameters:
        final theme = Theme.of(context);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 32,
                    child: Row(
                      children: [
                        Text(
                          "SCHEMA PARAMETERS",
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        LamiIconButton(
                          icon: LucideIcons.search,
                          onPressed: () {
                            // Focus search if needed
                          },
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Consumer(
                          builder: (context, ref, _) {
                            final filterByCategories = ref.watch(
                              schemaEditorProvider.select(
                                (s) => s.filterByCategories,
                              ),
                            );
                            return LamiIconButton(
                              icon: LucideIcons.filter,
                              onPressed: () {
                                ref
                                    .read(schemaEditorProvider.notifier)
                                    .toggleCategoryFilter();
                              },
                              color: filterByCategories
                                  ? theme.colorScheme.primary
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(width: AppSpacing.s),
                        LamiIconButton(
                          icon: LucideIcons.plus,
                          onPressed: () {
                            final state = ref.read(schemaEditorProvider);
                            final categories = state.schema.categories;
                            final defaultCat = categories.firstWhere(
                              (c) => c.categoryName == 'default',
                              orElse: () => categories.first,
                            );

                            final newParam = CamParamEntry(
                              paramName:
                                  'new_param_${state.schema.availableParameters.length + 1}',
                              paramTitle: 'New Parameter',
                              paramDescription: '',
                              quantity: const ParamQuantity(
                                quantityName: 'generic',
                                quantityUnit: '',
                                quantitySymbol: '',
                                quantityType: QuantityType.numeric,
                              ),
                              category: defaultCat,
                              value: 0,
                            );
                            ref
                                .read(schemaEditorProvider.notifier)
                                .addParameter(newParam);
                            ref
                                .read(schemaEditorProvider.notifier)
                                .selectParameter(newParam);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const Expanded(child: ParamListWidget()),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              flex: 6,
              child: Consumer(
                builder: (context, ref, _) {
                  final selectedParam = ref.watch(
                    schemaEditorProvider.select(
                      (s) => s.selectedParameter?.paramName,
                    ),
                  );
                  return ParamConfWidget(key: ValueKey(selectedParam));
                },
              ),
            ),
          ],
        );
    }
  }
}
