import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dialog_layout.dart';

class CategoryEditorDialog extends StatefulWidget {
  final CamCategoryEntry? category;
  final Function(CamCategoryEntry) onSave;

  const CategoryEditorDialog({super.key, this.category, required this.onSave});

  @override
  State<CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<CategoryEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late String _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?.categoryName ?? '',
    );
    _titleController = TextEditingController(
      text: widget.category?.categoryTitle ?? '',
    );
    _selectedColor = widget.category?.categoryColorName ?? 'blue';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LamiDialogLayout(
      actions: [
        LamiButton(
          label: "Cancel",
          icon: Icons.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
        LamiButton(
          label: "Save",
          icon: Icons.save,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                CamCategoryEntry(
                  categoryName: _nameController.text.trim(),
                  categoryTitle: _titleController.text.trim(),
                  categoryColorName: _selectedColor,
                ),
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Internal Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
                enabled:
                    widget.category == null ||
                    widget.category!.categoryName !=
                        'default', // Don't edit default name?
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Display Title'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              Text('Color', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: AppSpacing.s),
              Wrap(
                spacing: AppSpacing.s,
                runSpacing: AppSpacing.s,
                children: LamiColors.registry.entries.map((e) {
                  final isSelected = e.key == _selectedColor;
                  return InkWell(
                    onTap: () => setState(() => _selectedColor = e.key),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: e.value,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
