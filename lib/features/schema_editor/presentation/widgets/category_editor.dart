import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class CategoryEditor extends StatefulWidget {
  final CamCategoryEntry? category;
  final Function(CamCategoryEntry) onSave;
  final VoidCallback onCancel;

  const CategoryEditor({
    super.key,
    this.category,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<CategoryEditor> {
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

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        CamCategoryEntry(
          categoryName: _nameController.text.trim(),
          categoryTitle: _titleController.text.trim(),
          categoryColorName: _selectedColor,
          isVisible: widget.category?.isVisible ?? true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Internal Name'),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            enabled:
                widget.category == null ||
                widget.category!.categoryName != 'default',
          ),
          const SizedBox(height: AppSpacing.m),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Display Title'),
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Color', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.s),
          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: LamiColor.values.map((c) {
              final isSelected = c.name == _selectedColor;
              return InkWell(
                onTap: () => setState(() => _selectedColor = c.name),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: c.value,
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
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              LamiButton(
                label: "Cancel",
                icon: Icons.close,
                onPressed: widget.onCancel,
              ),
              const SizedBox(width: AppSpacing.m),
              LamiButton(
                label: "Save",
                icon: Icons.save,
                onPressed: _handleSave,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
