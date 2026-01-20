import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dialog_layout.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateLayerDialog extends ConsumerStatefulWidget {
  const CreateLayerDialog({super.key});

  @override
  ConsumerState<CreateLayerDialog> createState() => _CreateLayerDialogState();
}

class _CreateLayerDialogState extends ConsumerState<CreateLayerDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryScrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCategory == null) return;

      ref
          .read(layerPanelProvider.notifier)
          .addLayer(
            name: _nameController.text,
            description: _descriptionController.text,
            category: _selectedCategory!,
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(activeSchemaCategoriesProvider);
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: LamiDialogLayout(
        actions: [
          LamiButton(
            icon: LucideIcons.x,
            label: "Cancel",
            onPressed: () => Navigator.of(context).pop(),
          ),
          LamiButton(
            icon: LucideIcons.check,
            label: "Create",
            inactive: _selectedCategory == null,
            onPressed: _submit,
          ),
        ],
        children: [
          LamiDialogInput(
            label: "Name",
            controller: _nameController,
            hintText: "Enter layer name",
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty) return "Name is required";
              return null;
            },
          ),
          LamiDialogInput(
            label: "Description",
            controller: _descriptionController,
            hintText: "Enter layer description",
            maxLines: 3,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Category",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedCategory != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.25),
                    width: _selectedCategory != null ? 2 : 1,
                  ),
                ),
                child: categories.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: Text(
                          "No categories available in the current schema.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      )
                    : Scrollbar(
                        controller: _categoryScrollController,
                        child: SingleChildScrollView(
                          controller: _categoryScrollController,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: categories.map((category) {
                              return RadioListTile<String>(
                                title: Text(category.categoryTitle),
                                value: category.categoryName,
                                // ignore: deprecated_member_use
                                groupValue: _selectedCategory,
                                // ignore: deprecated_member_use
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.m,
                                ),
                                dense: true,
                                activeColor: theme.colorScheme.primary,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
