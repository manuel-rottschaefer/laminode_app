import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/category_editor.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoriesEditorWidget extends ConsumerStatefulWidget {
  const CategoriesEditorWidget({super.key});

  @override
  ConsumerState<CategoriesEditorWidget> createState() =>
      _CategoriesEditorWidgetState();
}

class _CategoriesEditorWidgetState
    extends ConsumerState<CategoriesEditorWidget> {
  CamCategoryEntry? _editingCategory;
  bool _isAddingNew = false;

  void _startEditing(CamCategoryEntry category) {
    setState(() {
      _editingCategory = category;
      _isAddingNew = false;
    });
  }

  void _startAdding() {
    setState(() {
      _editingCategory = null;
      _isAddingNew = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingCategory = null;
      _isAddingNew = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(
      schemaEditorProvider.select((s) => s.schema.categories),
    );
    final selectedCategory = ref.watch(
      schemaEditorProvider.select((s) => s.selectedCategory),
    );

    final theme = Theme.of(context);
    final allVisible = categories.every((c) => c.isVisible);
    final isEditing = _editingCategory != null || _isAddingNew;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing
                    ? (_isAddingNew ? 'ADD CATEGORY' : 'EDIT CATEGORY')
                    : 'CATEGORIES',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              if (!isEditing)
                Row(
                  children: [
                    LamiIconButton(
                      icon: allVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                      onPressed: () {
                        ref
                            .read(schemaEditorProvider.notifier)
                            .setAllCategoriesVisibility(!allVisible);
                      },
                    ),
                    const SizedBox(width: AppSpacing.s),
                    LamiIconButton(
                      icon: LucideIcons.plus,
                      onPressed: _startAdding,
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Expanded(
          child: LamiBox(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: isEditing
                ? CategoryEditor(
                    category: _editingCategory,
                    onSave: (cat) {
                      if (_isAddingNew) {
                        ref
                            .read(schemaEditorProvider.notifier)
                            .addCategory(cat);
                      } else {
                        ref
                            .read(schemaEditorProvider.notifier)
                            .updateCategory(
                              _editingCategory!.categoryName,
                              cat,
                            );
                      }
                      _cancelEditing();
                    },
                    onCancel: _cancelEditing,
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.s,
                          mainAxisSpacing: AppSpacing.s,
                          mainAxisExtent: 56, // Reduced from 64
                        ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected =
                          cat.categoryName == selectedCategory?.categoryName;

                      return _CategoryItem(
                        category: cat,
                        isSelected: isSelected,
                        onTap: () {
                          ref
                              .read(schemaEditorProvider.notifier)
                              .selectCategory(cat);
                        },
                        onToggleVisibility: () {
                          ref
                              .read(schemaEditorProvider.notifier)
                              .toggleCategoryVisibility(cat.categoryName);
                        },
                        onEdit: () => _startEditing(cat),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final CamCategoryEntry category;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;
  final VoidCallback onEdit;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.onToggleVisibility,
    required this.onEdit,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = widget.category;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: LamiBox(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          borderColor: widget.isSelected ? theme.colorScheme.primary : null,
          backgroundColor: widget.isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : null,
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _getColor(cat.categoryColorName),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.categoryTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cat.isVisible ? null : theme.disabledColor,
                        fontSize: 13, // Slightly reduced
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      cat.categoryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 10, // Restored to 10
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Controls row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: _isHovered ? 32.0 : 0.0,
                      child: ClipRect(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Opacity(
                              opacity: _isHovered ? 1.0 : 0.0,
                              child: LamiIconButton(
                                icon: LucideIcons.pencil,
                                onPressed: widget.onEdit,
                                size: 14,
                                padding: 5,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  LamiIconButton(
                    icon: cat.isVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                    onPressed: widget.onToggleVisibility,
                    size: 14,
                    padding: 5,
                    color: cat.isVisible ? null : theme.disabledColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(String colorName) {
    return LamiColor.fromString(colorName).value;
  }
}
