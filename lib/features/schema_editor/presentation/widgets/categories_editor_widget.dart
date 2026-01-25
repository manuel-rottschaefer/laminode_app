import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/presentation/dialogs/category_editor_dialog.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoriesEditorWidget extends ConsumerWidget {
  const CategoriesEditorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(
      schemaEditorProvider.select((s) => s.schema.categories),
    );
    final selectedCategory = ref.watch(
      schemaEditorProvider.select((s) => s.selectedCategory),
    );

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORIES',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              LamiIconButton(
                icon: LucideIcons.plus,
                onPressed: () {
                  showLamiDialog(
                    context: context,
                    model: LamiDialogModel(
                      title: "Add Category",
                      content: CategoryEditorDialog(
                        onSave: (cat) {
                          ref
                              .read(schemaEditorProvider.notifier)
                              .addCategory(cat);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Expanded(
          child: LamiBox(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.s,
                mainAxisSpacing: AppSpacing.s,
                mainAxisExtent: 48,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected =
                    cat.categoryName == selectedCategory?.categoryName;

                return InkWell(
                  onTap: () {
                    ref.read(schemaEditorProvider.notifier).selectCategory(cat);
                  },
                  child: LamiBox(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    borderColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    backgroundColor: isSelected
                        ? Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.1)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getColor(cat.categoryColorName),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Text(
                            cat.categoryTitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: cat.isVisible
                                      ? null
                                      : Theme.of(context).disabledColor,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            cat.isVisible
                                ? LucideIcons.eye
                                : LucideIcons.eyeOff,
                            size: 14,
                          ),
                          onPressed: () {
                            ref
                                .read(schemaEditorProvider.notifier)
                                .toggleCategoryVisibility(cat.categoryName);
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          splashRadius: 16,
                          color: cat.isVisible
                              ? null
                              : Theme.of(context).disabledColor,
                        ),
                        if (isSelected)
                          IconButton(
                            icon: const Icon(LucideIcons.pencil, size: 14),
                            onPressed: () {
                              showLamiDialog(
                                context: context,
                                model: LamiDialogModel(
                                  title: "Edit Category",
                                  content: CategoryEditorDialog(
                                    category: cat,
                                    onSave: (newCat) {
                                      ref
                                          .read(schemaEditorProvider.notifier)
                                          .updateCategory(
                                            cat.categoryName,
                                            newCat,
                                          );
                                    },
                                  ),
                                ),
                              );
                            },
                            constraints: const BoxConstraints(),
                            splashRadius: 16,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor(String colorName) {
    return LamiColor.fromString(colorName).value;
  }
}
