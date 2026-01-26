import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';

class ParamConfGeneralSection extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController unitController;
  final VoidCallback onUpdate;

  const ParamConfGeneralSection({
    super.key,
    required this.nameController,
    required this.titleController,
    required this.descController,
    required this.unitController,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schemaEditorProvider);
    final param = state.selectedParameter!;
    final categories = state.schema.categories;

    return LamiBox(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: LamiDialogInput(
                  label: 'Internal Name',
                  controller: nameController,
                  isDense: true,
                  onChanged: (_) => onUpdate(),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: LamiDialogInput(
                  label: 'Display Title',
                  controller: titleController,
                  isDense: true,
                  onChanged: (_) => onUpdate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          LamiDialogInput(
            label: 'Description',
            controller: descController,
            maxLines: 2,
            isDense: true,
            onChanged: (_) => onUpdate(),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 45,
                child: LamiDialogDropdown<String>(
                  label: 'Category',
                  value: param.category.categoryName,
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.categoryName,
                          child: Text(c.categoryTitle),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final newCat = categories.firstWhere(
                        (c) => c.categoryName == val,
                      );
                      final newParam = param.copyWith(category: newCat);
                      ref
                          .read(schemaEditorProvider.notifier)
                          .updateParameter(param.paramName, newParam);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                flex: 30,
                child: LamiDialogDropdown<QuantityType>(
                  label: 'Type',
                  value: param.quantity.quantityType,
                  items: QuantityType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final newParam = param.copyWith(
                        quantity: ParamQuantity(
                          quantityName: param.quantity.quantityName,
                          quantityUnit: param.quantity.quantityUnit,
                          quantitySymbol: param.quantity.quantitySymbol,
                          quantityType: val,
                          options: param.quantity.options,
                        ),
                        value: _getDefaultValueForType(val),
                      );
                      ref
                          .read(schemaEditorProvider.notifier)
                          .updateParameter(param.paramName, newParam);
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                flex: 25,
                child: LamiDialogInput(
                  label: 'Unit (e.g. mm, %)',
                  controller: unitController,
                  isDense: true,
                  onChanged: (_) => onUpdate(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  dynamic _getDefaultValueForType(QuantityType type) {
    switch (type) {
      case QuantityType.numeric:
        return 0.0;
      case QuantityType.boolean:
        return false;
      case QuantityType.choice:
        return '';
    }
  }
}
