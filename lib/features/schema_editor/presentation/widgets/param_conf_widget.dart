import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_conf_general_section.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_conf_expression_section.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ParamConfWidget extends ConsumerStatefulWidget {
  const ParamConfWidget({super.key});

  @override
  ConsumerState<ParamConfWidget> createState() => _ParamConfWidgetState();
}

class _ParamConfWidgetState extends ConsumerState<ParamConfWidget> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final param = ref.read(schemaEditorProvider).selectedParameter;
    _nameController = TextEditingController(text: param?.paramName ?? '');
    _titleController = TextEditingController(text: param?.paramTitle ?? '');
    _descController = TextEditingController(
      text: param?.paramDescription ?? '',
    );
    _unitController = TextEditingController(
      text: param?.quantity.quantityUnit ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant ParamConfWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _updateParam() {
    final state = ref.read(schemaEditorProvider);
    final param = state.selectedParameter;
    if (param == null) return;

    final newParam = param.copyWith(
      paramName: _nameController.text,
      paramTitle: _titleController.text,
      paramDescription: _descController.text,
      quantity: ParamQuantity(
        quantityName: param.quantity.quantityName,
        quantityUnit: _unitController.text,
        quantitySymbol: param.quantity.quantitySymbol,
        quantityType: param.quantity.quantityType,
        options: param.quantity.options,
      ),
    );
    ref
        .read(schemaEditorProvider.notifier)
        .updateParameter(param.paramName, newParam);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schemaEditorProvider);
    final param = state.selectedParameter;

    if (param == null) {
      return const Center(child: Text("Select a parameter to edit"));
    }

    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 32,
            child: Row(
              children: [
                Text(
                  "PARAMETER CONFIGURATION",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const Spacer(),
                LamiIconButton(
                  icon: LucideIcons.trash2,
                  color: theme.colorScheme.error,
                  onPressed: () {
                    ref
                        .read(schemaEditorProvider.notifier)
                        .deleteParameter(param.paramName);
                  },
                ),
                const SizedBox(width: AppSpacing.s),
                LamiIconButton(
                  icon: LucideIcons.rotateCcw,
                  onPressed: () {
                    ref
                        .read(schemaEditorProvider.notifier)
                        .selectParameter(null);
                  },
                ),
                const SizedBox(width: AppSpacing.s),
                LamiIconButton(
                  icon: LucideIcons.save,
                  color: theme.colorScheme.primary,
                  onPressed: _updateParam,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          ParamConfGeneralSection(
            nameController: _nameController,
            titleController: _titleController,
            descController: _descController,
            unitController: _unitController,
            onUpdate: () {}, // Removed auto-update
          ),
          const SizedBox(height: AppSpacing.m),
          const ParamConfExpressionSection(),
        ],
      ),
    );
  }
}
